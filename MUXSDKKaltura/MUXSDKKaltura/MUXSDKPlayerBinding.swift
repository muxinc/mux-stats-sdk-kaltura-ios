//
//  MUXSDKPlayerBinding.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import PlayKit
import MuxCore
import AVFoundation

@objc
public class MUXSDKPlayerBinding: NSObject {
    private let MUXSDKPluginName = "apple-mux"
    private let MUXSDKPluginVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    // Min number of seconds between timeupdate events. (100ms)
    private let MUXSDKMaxSecsBetweenTimeUpdate = 0.1
    // Number of seconds of difference between wall/play time signaling the beginning of a seek. (200ms)
    private let MUXSDKMaxSecsSeekClockDrift = 0.2;
    // Number of seconds the playhead has to move from the last known playhead position when
    // restarting play to consider the transition to play a seek. (500ms)
    private let MUXSDKMaxSecsSeekPlayheadShift = 0.5;
    
    private var name: String
    private var software: String
    private var player: Player?
    private var automaticErrorTracking: Bool
    private let dispatcher: MUXSDKDispatcher
    
    private var lastTimeUpdate: TimeInterval = .zero
    private var timeObserver: UUID? = nil
    
    private var currentPlayheadTimeMs: Double {
        return self.player?.currentTime ?? 0.0 * 1000
    }
    
    // Binding is considered initialized once it has dispatched the viewInit, customer player & video data, & playerReady events to MUXCore
    private (set) var initialized: Bool
    private var state: MUXSDKPlayerState
    private var videoData = VideoData()
    
    init(
        name: String,
        software: String,
        player: Player,
        automaticErrorTracking: Bool,
        dispatcher: MUXSDKDispatcher
    ) {
        self.name = name
        self.software = software
        self.player = player
        self.automaticErrorTracking = automaticErrorTracking
        self.dispatcher = dispatcher
        self.initialized = false
        self.state = .unknown
    }
    
    func initialize() {
        // Once the binding is initialized it can't go back to false
        self.initialized = true
    }
    
    func attachPlayer(_ player: Player) {
        if self.player != nil {
            self.detachPlayer()
        }
        
        self.player = player
        
        self.registerToPlayerEvents()
        
        self.lastTimeUpdate = Date.timeIntervalSinceReferenceDate - MUXSDKMaxSecsBetweenTimeUpdate
        self.timeObserver = self.player?.addPeriodicObserver(
            interval: MUXSDKMaxSecsBetweenTimeUpdate,
            observeOn: nil,
            using: { [weak self] timeInterval in
                guard let self = self else { return }
                
                switch self.state {
                case .play:
                    // Is trying to play
                    self.state = .buffering
                case .buffering:
                    self.dispatchPlaying()
                default:
                    self.dispatchTimeUpdate(timeInterval)
                }
                
                self.computeDrift()
                self.updateLastPlayheadTime()
            }
        )
        

    }
    
    func detachPlayer() {
        self.player = nil
    }
    
    func registerToPlayerEvents() {
        self.player?.addObserver(
            self,
            events: [
                PlayerEvent.sourceSelected,
                PlayerEvent.durationChanged,
                PlayerEvent.videoTrackChanged,
                PlayerEvent.error,
                PlayerEvent.errorLog
            ]
        ) { [weak self] (event) in
            guard let self = self else { return }
            
            switch event {
            case is PlayerEvent.SourceSelected:
                if let source = event.mediaSource {
                    self.videoData.url = source.contentUrl?.absoluteString
                    self.videoData.hasUpdates = true
                }
            case is PlayerEvent.DurationChanged:
                if let duration = event.duration as? TimeInterval {
                    self.videoData.duration = duration
                    self.videoData.hasUpdates = true
                }
            case is PlayerEvent.VideoTrackChanged:
                // This event indicates a change in the property indicatedBitrate
                if let bitrate = event.bitrate?.doubleValue {
                    guard self.videoData.lastAdvertisedBitrate != 0 else {
                        // Starting Playback
                        self.videoData.lastAdvertisedBitrate = bitrate
                        return
                    }
                    
                    print("MUXSDK-INFO - Switch advertised bitrate from: \(self.videoData.lastAdvertisedBitrate) to: \(bitrate)")
                    
                    self.videoData.lastAdvertisedBitrate = bitrate
                    guard self.videoData.lastDispatchedAdvertisedBitrate != self.videoData.lastAdvertisedBitrate else {
                        return
                    }
                    
                    self.videoData.sourceDimensionsHaveChanged = true
                    self.videoData.hasUpdates = true
                    self.dispatchRenditionChange()
                }
            case is PlayerEvent.Error, is PlayerEvent.ErrorLog:
                if let error = event.error {
                    self.videoData.playerErrors.append(
                        Error(
                            level: event is PlayerEvent.Error ? .player : .log,
                            domain: error.domain,
                            code: error.code,
                            message: error.localizedDescription
                        )
                    )
                }
            default:
                break
            }
        }
    }
    
    func getPlayerData() -> MUXSDKPlayerData {
        let playerData = MUXSDKPlayerData()
        
        playerData.playerMuxPluginName = MUXSDKPluginName
        playerData.playerMuxPluginVersion = MUXSDKPluginVersion
        playerData.playerSoftwareName = self.software
        playerData.playerLanguageCode = Locale.current.languageCode
        
        guard let player = self.player else {
            return playerData
        }
        
        if let playerLayer = player.view?.layer as? AVPlayerLayer {
            let videoBounds = playerLayer.videoRect
            playerData.playerWidth = NSNumber(value: videoBounds.width.native)
            playerData.playerHeight = NSNumber(value: videoBounds.height.native)
            
            if let avPlayer = playerLayer.player {
                if avPlayer.isExternalPlaybackActive {
                    playerData.playerRemotePlayed = NSNumber(true)
                }
            }
        }
        
        var isFullScreen: Bool {
            guard let viewBounds = player.view?.bounds else {
                return false
            }
            
            let screenBounds = UIScreen.main.bounds
            
            return
                viewBounds.size.equalTo(screenBounds.size) ||
                (viewBounds.size.width == screenBounds.size.height && viewBounds.size.height == screenBounds.size.width)
        }

        playerData.playerIsFullscreen = isFullScreen ? "true" : "false"

        // Derived from the player.
        let errors = videoData.playerErrors
        
        if player.currentState == .error, let playerError = errors.last(where: { $0.level == .player }) {
            playerData.playerErrorCode = String(playerError.code)
            playerData.playerErrorMessage = playerError.message
            
            // Send errorLogs only if there's at least one player error
            if
                let jsonData = try? JSONEncoder().encode(errors),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                playerData.playeriOSErrorData = jsonString
            }
        } else {
            // FIXME: Confirm if we just want to set playerIsPaused and playerPlayheadTime in case that is not in error state
            playerData.playerIsPaused = NSNumber(value: player.rate == 0.0)
            playerData.playerPlayheadTime = NSNumber(value: Int64(player.currentTime * 1000))
        }
        
        return playerData
    }
    
    func computeDrift() {
        guard videoData.started else {
            // Avoid computing drift until playback has started (meaning play has been called).
            return
        }

        // Determing if we are seeking by infering that we went into the pause state and the playhead moved a lot.
        let playheadTimeElapsed = (self.currentPlayheadTimeMs - self.videoData.lastPlayheadTimeMs)/1000
        let wallTimeElapsed = Date.timeIntervalSinceReferenceDate - self.videoData.lastPlayheadTimeUpdated
        let drift = playheadTimeElapsed - wallTimeElapsed
        
        // The playhead has to have moved > 500ms and we have to have signifigantly drifted in comparision to wall time.
        // We check both positive and negative to account for seeking forward and backward respectively.
        // Unbuffered seeks seem to update the playhead time when transitioning into play where as buffered seeks update the playhead time when paused.
        
        if
            abs(playheadTimeElapsed) > MUXSDKMaxSecsSeekPlayheadShift,
            abs(drift) > MUXSDKMaxSecsSeekClockDrift,
            self.state == .paused || self.state == .play
        {
            videoData.seeking = true
            let event = MUXSDKInternalSeekingEvent()
            let playerData = self.getPlayerData()
            
            if UIDevice.current.userInterfaceIdiom == .tv {
                playerData.playerPlayheadTime = NSNumber(value: Int64(self.videoData.lastPlayheadTimeMsOnPause * 1000))
            }
            
            event.playerData = playerData
            self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        }
    }
    
    func updateLastPlayheadTime() {
        self.videoData.lastPlayheadTimeMs = self.currentPlayheadTimeMs
        self.videoData.lastPlayheadTimeUpdated = Date.timeIntervalSinceReferenceDate
    }
    
    func updateLastPlayheadTimeOnPause() {
        self.videoData.lastPlayheadTimeMsOnPause = self.currentPlayheadTimeMs
        self.videoData.lastPlayheadTimeOnPauseUpdated = Date.timeIntervalSinceReferenceDate
    }
    
    func checkVideoData(player: Player) {
        let currentVideoIsLive = player.isLive()
        let liveUpdates = videoData.isLive != currentVideoIsLive
        
        let videoDataUpdated = videoData.hasUpdates || liveUpdates

        if self.videoData.sourceDimensionsHaveChanged, self.videoData.size.equalTo(self.videoData.lastDispatchedVideoSize) {
            let sourceDimensions = self.getSourceDimensions()
            if !self.videoData.size.equalTo(sourceDimensions) {
                self.videoData.size = sourceDimensions
                
                if sourceDimensions.width > 0, sourceDimensions.height > 0 {
                    self.videoData.sourceDimensionsHaveChanged = false
                }
            }
        }
        
        guard videoDataUpdated else {
            return
        }
        
        let eventVideoData = MUXSDKVideoData()
        
        if self.videoData.size.width > 0, self.videoData.size.height > 0 {
            eventVideoData.videoSourceWidth = NSNumber(value: self.videoData.size.width.native)
            eventVideoData.videoSourceHeight = NSNumber(value: self.videoData.size.height.native)
            self.videoData.lastDispatchedVideoSize = self.videoData.size
        }
        
        if currentVideoIsLive {
            self.videoData.isLive = true
            eventVideoData.videoSourceIsLive = "true"
        } else {
            eventVideoData.videoSourceIsLive = "false"
            if self.videoData.duration > 0 {
                eventVideoData.videoSourceDuration = NSNumber(value: Int64(self.videoData.duration * 1000))
            }
        }
        
        eventVideoData.videoSourceUrl = videoData.url
        
        if (self.videoData.lastAdvertisedBitrate > 0) {
            eventVideoData.videoSourceAdvertisedBitrate = NSNumber(value: self.videoData.lastAdvertisedBitrate)
            self.videoData.lastDispatchedAdvertisedBitrate = self.videoData.lastAdvertisedBitrate
        }
        
        let event = MUXSDKDataEvent()
        event.videoData = eventVideoData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.videoData.hasUpdates = false
    }
    
    func getSourceDimensions() -> CGSize {
        guard
            let playerLayer = player?.view?.layer as? AVPlayerLayer,
            let currentItem = playerLayer.player?.currentItem
        else {
            return .zero
        }
        
        for track in currentItem.tracks {
            // loop until first track with video description
            if let formatDescriptions = track.assetTrack?.formatDescriptions as? [CMFormatDescription] {
                for description in formatDescriptions {
                    var isVideoDescription: Bool {
                        // Remove the conditional if we drop support for iOS < 13.0
                        if #available(iOS 13.0, *) {
                            return description.mediaType == .video
                        } else {
                            return CMFormatDescriptionGetMediaType(description) == kCMMediaType_Video
                        }
                    }
                    
                    if isVideoDescription {
                        // Map video dimensions in pixels
                        var dimensions: CMVideoDimensions {
                            // Remove the conditional if we drop support for iOS < 13.0
                            if #available(iOS 13.0, *) {
                                return description.dimensions
                            } else {
                                return CMVideoFormatDescriptionGetDimensions(description)
                            }
                        }
                        
                        return CGSize(width: Int(dimensions.width), height: Int(dimensions.height))
                    }
                }
            }
        }
        
        return .zero
    }
}

// MARK: Dispatch Events
extension MUXSDKPlayerBinding {
    func dispatchViewInit() {
        guard self.player != nil else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        // Reset video data
        self.videoData = VideoData()
        
        let event = MUXSDKViewInitEvent()
        event.playerData = self.getPlayerData()
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .viewInit
    }
    
    func dispatchPlayerReady() {
        guard self.player != nil else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        let event = MUXSDKPlayerReadyEvent()
        event.playerData = self.getPlayerData()
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .ready
    }
    
    func dispatchPlaying() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.checkVideoData(player: player)
        let playerData = self.getPlayerData()
        
        if videoData.seeking {
            videoData.seeking = false
            let seekedEvent = MUXSDKSeekedEvent()
            seekedEvent.playerData = playerData
            self.dispatcher.dispatchEvent(seekedEvent, forPlayer: self.name)
        }
        
        let event = MUXSDKPlayingEvent()
        event.playerData = playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .playing
    }
    
    func dispatchTimeUpdate(_ time: TimeInterval) {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        guard self.state != .playing else {
            return
        }
        
        // Check to make sure we don't over work.
        let currentTime = Date.timeIntervalSinceReferenceDate
        guard (currentTime - self.lastTimeUpdate >= MUXSDKMaxSecsBetweenTimeUpdate) else {
            return
        }
        self.lastTimeUpdate = currentTime
        
        self.checkVideoData(player: player)
        let playerData = self.getPlayerData()
        
        let event = MUXSDKTimeUpdateEvent()
        event.playerData = playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
    }
    
    func dispatchRenditionChange() {
        // Dispatch MUXSDKRenditionChangeEvent
    }
}

extension MUXSDKPlayerBinding {
    enum MUXSDKPlayerState {
        case ready
        case viewInit
        case play
        case buffering
        case playing
        case paused
        case error
        case viewEnd
        case unknown
    }
}
