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
    private let MUXSDKPluginName = "apple-kaltura-mux"
    private let MUXSDKPluginVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    // Min number of seconds between timeupdate events. (100ms)
    private let MUXSDKMinSecsBetweenTimeUpdate = 0.1
    
    private var name: String
    private var software: String
    private var player: Player?
    private var automaticErrorTracking: Bool
    private var automaticVideoChange: Bool
    var manualVideoChangeTriggered: Bool
    private let dispatcher: MUXSDKDispatcher
    private let playDispatchDelegate: PlayDispatchDelegate
    
    private var lastTimeUpdate: TimeInterval = .zero
    private var timeObserver: UUID? = nil
    private var timeUpdateTimer: Timer? = nil
    
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
        automaticErrorTracking: Bool,
        playDispatchDelegate: PlayDispatchDelegate,
        dispatcher: MUXSDKDispatcher
    ) {
        self.name = name
        self.software = software
        self.automaticErrorTracking = automaticErrorTracking
        self.manualVideoChangeTriggered = false
        self.automaticVideoChange = true
        self.playDispatchDelegate = playDispatchDelegate
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
        
        self.registerForPlayerEvents()
        
        self.lastTimeUpdate = Date.timeIntervalSinceReferenceDate - MUXSDKMinSecsBetweenTimeUpdate
        self.timeObserver = self.player?.addPeriodicObserver(
            interval: MUXSDKMinSecsBetweenTimeUpdate,
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
            }
        )
        
        self.timeUpdateTimer = Timer.scheduledTimer(
            timeInterval: 0.05,
            target: self,
            selector: #selector(self.dispatchTimeUpdateFromTimer),
            userInfo: nil,
            repeats: true
        )
        
        self.addAVPlayerObservers()
        
        // Reset bitrate and bandwidth properties for updatePlayer
        self.videoData.lastTransferEventCount = 0
        self.videoData.lastTransferDuration = 0
        self.videoData.lastTransferredBytes = 0
        self.videoData.lastAdvertisedBitrate = 0
        self.videoData.lastDispatchedAdvertisedBitrate = 0
    }
    
    func detachPlayer() {
        if let periodicObserver = self.timeObserver {
            self.player?.removePeriodicObserver(periodicObserver)
        }
        
        self.player?.removeObserver(
            self,
            events: [
                PlayerEvent.sourceSelected,
                PlayerEvent.durationChanged,
                PlayerEvent.videoTrackChanged,
                PlayerEvent.seeking,
                PlayerEvent.seeked,
                PlayerEvent.playbackRate,
                PlayerEvent.pause,
                PlayerEvent.stateChanged,
                PlayerEvent.error,
                PlayerEvent.errorLog
            ]
        )
        
        self.removeAVPlayerObservers()
        
        self.dispatcher.destroyPlayer(self.name)
        self.player = nil
        
        self.timeUpdateTimer?.invalidate()
        self.timeUpdateTimer = nil
    }
    
    @objc
    private func dispatchTimeUpdateFromTimer() {
        guard self.state == .buffering || self.state == .play, let player = self.player else {
            return
        }
        
        self.dispatchTimeUpdate(player.currentTime)
    }
    
    private func registerForPlayerEvents() {
        self.player?.addObserver(
            self,
            events: [
                PlayerEvent.sourceSelected,
                PlayerEvent.durationChanged,
                PlayerEvent.videoTrackChanged,
                PlayerEvent.seeking,
                PlayerEvent.seeked,
                PlayerEvent.playbackRate,
                PlayerEvent.pause,
                PlayerEvent.stateChanged,
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
                    self.handleRenditionChange(bitrate: bitrate)
                }
            case is PlayerEvent.Seeking:
                self.dispatchSeekingEvent()
            case is PlayerEvent.Seeked:
                self.dispatchSeekedEvent()
            case is PlayerEvent.PlaybackRate:
                guard self.state != .play, self.state != .playing else {
                    return
                }
                
                self.dispatchPlay()
            case is PlayerEvent.Pause:
                guard self.state == .play || self.state == .playing else {
                    return
                }
                
                self.dispatchPause()
            case is PlayerEvent.StateChanged:
                switch event.newState {
                case .idle:
                    // Internally Kaltura emits a state change and sets new state to idle on handleItemChange
                    self.monitorPlayerItem()
                case .buffering:
                    self.handleRebufferingInAirplayMode()
                default:
                    return
                }
            case is PlayerEvent.Error, is PlayerEvent.ErrorLog:
                // Gather errors for player data
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
                
                // Dispatch error event for automatic tracking
                guard self.player?.currentState == .error else {
                   return
                }
                
                self.dispatchError()
            default:
                break
            }
        }
    }
    
    private func addAVPlayerObservers() {
        // Kaltura posts a playback info event for this notification, but it doesn't contain the data we require so we need to implement our own listener to get the full access log
        NotificationCenter.default.addObserver(self, selector: #selector(self.getBandwidthMetric), name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAVPlayerErrorLog), name: .AVPlayerItemNewErrorLogEntry, object: nil)
    }
    
    private func removeAVPlayerObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
    }
    
    private var playerData: MUXSDKPlayerData {
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
            
            var equalToScreenBounds: Bool {
                let screenBounds = UIScreen.main.bounds
                return
                    viewBounds.size.equalTo(screenBounds.size) ||
                    (viewBounds.size.width == screenBounds.size.height && viewBounds.size.height == screenBounds.size.width)
            }
            
            var equalToSafeArea: Bool {
                guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                    return false
                }
                
                var safeAreaBounds = CGSize.zero
                // Remove conditional when we drop support for iOS < 11.0
                if #available(iOS 11.0, *) {
                    safeAreaBounds = rootViewController.view.safeAreaLayoutGuide.layoutFrame.size
                } else {
                    // Fallback on earlier versions
                    let topSafeArea = rootViewController.topLayoutGuide.length
                    let bottomSafeArea = rootViewController.bottomLayoutGuide.length
                    let fullViewSize = rootViewController.view.frame.size
                    safeAreaBounds = CGSize(width: fullViewSize.width, height: fullViewSize.height - topSafeArea - bottomSafeArea)
                }
                
                return
                    viewBounds.size.equalTo(safeAreaBounds) ||
                    (viewBounds.size.width == safeAreaBounds.height && viewBounds.size.height == safeAreaBounds.width)
            }
            
            
            return equalToScreenBounds || equalToSafeArea
        }

        playerData.playerIsFullscreen = String(isFullScreen)

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
            playerData.playerIsPaused = NSNumber(value: player.rate == 0.0)
            playerData.playerPlayheadTime = NSNumber(value: Int64(player.currentTime * 1000))
        }
        
        return playerData
    }
    
    private func updateLastPlayheadTimeOnPause() {
        self.videoData.lastPlayheadTimeMsOnPause = self.currentPlayheadTimeMs
    }
    
    private func updateVideoData(player: Player) {
        let currentVideoIsLive = player.isLive()
        let liveUpdates = videoData.isLive != currentVideoIsLive
        
        let videoDataUpdated = videoData.hasUpdates || liveUpdates

        if self.videoData.sourceDimensionsHaveChanged, self.videoData.size.equalTo(self.videoData.lastDispatchedVideoSize) {
            let sourceDimensions = player.sourceDimensions
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
        
        self.videoData.isLive = currentVideoIsLive
        eventVideoData.videoSourceIsLive = String(self.videoData.isLive)
        
        if !currentVideoIsLive, self.videoData.duration > 0 {
            eventVideoData.videoSourceDuration = NSNumber(value: Int64(self.videoData.duration * 1000))
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
    
    private func handleRenditionChange(bitrate: Double) {
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
    
    // FIXME: test if needed and if it works as expected
    func handleRebufferingInAirplayMode() {
        guard
            #available(iOS 10.0, *),
            let playerLayer = player?.view?.layer as? AVPlayerLayer,
            let player = playerLayer.player,
            player.timeControlStatus != .playing,
            player.isExternalPlaybackActive,
            self.state == .paused
        else {
            return
        }
        
        // We erroneously detected a pause when in fact we are rebuffering. This *only* happens in AirPlay mode
        self.dispatchPlay()
        self.dispatchPlaying()
    }
    
    private func monitorPlayerItem() {
        guard
            manualVideoChangeTriggered,
            self.player?.currentItem != nil
        else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player current item for player name: \(self.name)")
            return
        }
        
        manualVideoChangeTriggered = false
        self.dispatcher.destroyPlayer(self.name)
        self.playDispatchDelegate.videoChangedForPlayer(name: self.name)
    }
    
    private func getHost(urlString: String?) -> String? {
        guard let urlString = urlString else {
            return nil
        }
        
        let host = URL(string: urlString)?.host
        return host ?? urlString
    }
    
    @objc
    private func getBandwidthMetric(notification: Notification) {
        guard
            let playerItem = notification.object as? AVPlayerItem,
            playerItem == self.player?.currentItem, // Confirm notification is relevant to current player item
            let accessLog = playerItem.accessLog(),
            let event = accessLog.events.last
        else {
            return
        }
        
        if self.videoData.lastTransferEventCount != accessLog.events.count {
            self.videoData.lastTransferEventCount = accessLog.events.count
            self.videoData.lastTransferDuration = 0
            self.videoData.lastTransferredBytes = 0
        }
        
        let requestCompletedTime = Date().timeIntervalSince1970
        let requestStartSecs = requestCompletedTime - (event.transferDuration - self.videoData.lastTransferDuration)
        
        let data = MUXSDKBandwidthMetricData()
        data.requestType = "media"
        data.requestStart = NSNumber(value: requestStartSecs * 1000)
        data.requestResponseEnd = NSNumber(value: Int(requestCompletedTime * 1000))
        data.requestBytesLoaded = NSNumber(value: event.numberOfBytesTransferred - self.videoData.lastTransferredBytes)
        data.requestHostName = self.getHost(urlString: event.uri)
        
        self.dispatchBandwidthMetric(data: data, type: MUXSDKPlaybackEventRequestBandwidthEventCompleteType)

        self.videoData.lastTransferredBytes = event.numberOfBytesTransferred
        self.videoData.lastTransferDuration = event.transferDuration
    }
    
    @objc
    private func handleAVPlayerErrorLog(notification: Notification) {
        guard
            let playerItem = notification.object as? AVPlayerItem,
            playerItem == self.player?.currentItem, // Confirm notification is relevant to current player item
            let errorLog = playerItem.errorLog(),
            let errorEvent = errorLog.events.last
        else {
            return
        }
        
        let data = MUXSDKBandwidthMetricData()
        data.requestError = errorEvent.errorDomain
        data.requestType = "media"
        data.requestUrl = errorEvent.uri
        data.requestHostName = self.getHost(urlString: errorEvent.uri)
        data.requestErrorCode = NSNumber(value: errorEvent.errorStatusCode)
        data.requestErrorText = errorEvent.errorComment
        
        self.dispatchBandwidthMetric(data: data, type: MUXSDKPlaybackEventRequestBandwidthEventErrorType)
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
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .viewInit
    }
    
    func dispatchPlayerReady() {
        guard self.player != nil else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        let event = MUXSDKPlayerReadyEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .ready
    }
    
    private func dispatchPlaying() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKPlayingEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .playing
    }
    
    private func dispatchTimeUpdate(_ time: TimeInterval) {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        guard self.state != .playing else {
            return
        }
        
        // Check to make sure we don't over work.
        let currentTime = Date.timeIntervalSinceReferenceDate
        guard (currentTime - self.lastTimeUpdate >= MUXSDKMinSecsBetweenTimeUpdate) else {
            return
        }
        self.lastTimeUpdate = currentTime
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKTimeUpdateEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
    }
    
    private func dispatchSeekingEvent() {
        guard self.videoData.started, !self.videoData.seeking else {
            // Avoid computing drift until playback has started (meaning play has been called).
            return
        }
        
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.videoData.lastSeekingPlayheadTimeMs = self.currentPlayheadTimeMs
        self.videoData.seeking = true
        
        self.updateVideoData(player: player)
        let playerData = self.playerData
        
        if UIDevice.current.userInterfaceIdiom == .tv {
            playerData.playerPlayheadTime = NSNumber(value: Int64(self.videoData.lastPlayheadTimeMsOnPause))
        }
        
        let event = MUXSDKInternalSeekingEvent()
        event.playerData = playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
    }
    
    private func dispatchSeekedEvent() {
        guard
            self.videoData.seeking,
            let player = self.player,
            self.currentPlayheadTimeMs != self.videoData.lastSeekingPlayheadTimeMs
        else {
            return
        }
        
        self.videoData.seeking = false
        self.updateVideoData(player: player)

        let seekedEvent = MUXSDKSeekedEvent()
        seekedEvent.playerData = self.playerData
        self.dispatcher.dispatchEvent(seekedEvent, forPlayer: self.name)
    }
    
    private func dispatchRenditionChange() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKRenditionChangeEvent()
        event.playerData = self.playerData
        
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
    }
    
    private func dispatchPlay() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.playDispatchDelegate.playbackStartedForPlayer(name: name)
        
        self.videoData.started = true
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKPlayEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .play
    }
    
    private func dispatchPause() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        self.updateLastPlayheadTimeOnPause()
        
        let event = MUXSDKPauseEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .paused
    }
    
    private func dispatchBandwidthMetric(data: MUXSDKBandwidthMetricData, type: String) {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKRequestBandwidthEvent()
        event.type = type
        event.playerData = self.playerData
        event.bandwidthMetricData = data
        
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
    }
    
    private func dispatchError() {
        guard automaticErrorTracking else {
            return
        }
        
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        
        let event = MUXSDKErrorEvent()
        event.playerData = self.playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .error
    }
    
    public func dispatchError(code: String, message: String) {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        let playerData = self.playerData
        playerData.playerErrorCode = code
        playerData.playerErrorMessage = message
        
        let event = MUXSDKErrorEvent()
        event.playerData = playerData
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        
        self.state = .error
    }
    
    func dispatchViewEnd() {
        guard let player = self.player else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player for player name: \(self.name)")
            return
        }
        
        self.updateVideoData(player: player)
        let event = MUXSDKViewEndEvent()
        event.playerData = self.playerData
        
        self.dispatcher.dispatchEvent(event, forPlayer: self.name)
        self.state = .viewEnd
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

protocol PlayDispatchDelegate {
    func playbackStartedForPlayer(name: String)
    func videoChangedForPlayer(name: String)
}
