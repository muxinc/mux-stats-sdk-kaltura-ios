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
    
    private var name: String
    private var software: String
    private var player: Player?
    private var automaticErrorTracking: Bool
    private let dispatcher: MUXSDKDispatcher
    
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
        
        self.registerErrorsFromPlayer()

    }
    
    func detachPlayer() {
        self.player = nil
    }
    
    func registerErrorsFromPlayer() {
        self.player?.addObserver(
            self,
            events: [PlayerEvent.error, PlayerEvent.errorLog]
        ) { [weak self] (event) in
            guard let self = self else { return }
            
            switch event {
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
        
        if let layer = player.view?.layer as? AVPlayerLayer {
            let videoBounds = layer.videoRect
            playerData.playerWidth = NSNumber(value: videoBounds.width.native)
            playerData.playerHeight = NSNumber(value: videoBounds.height.native)
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
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
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
            playerData.playerIsPaused = NSNumber(value: player.rate == 0.0)
            playerData.playerPlayheadTime = NSNumber(value: Int64(player.currentTime * 1000))
        }

        if let playerLayer = player.view?.layer as? AVPlayerLayer, let avPlayer = playerLayer.player {
            if avPlayer.isExternalPlaybackActive {
                playerData.playerRemotePlayed = NSNumber(true)
            }
        }
        
        return playerData
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
