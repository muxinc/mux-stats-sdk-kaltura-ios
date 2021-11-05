//
//  ViewController.swift
//  DemoApp
//
//  Created by Stephanie Zuñiga on 20/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import UIKit
import PlayKit
import MUXSDKKaltura
import MuxCore

class PlayerViewController: UIViewController {
    var kalturaPlayer: Player?
    let kalturaPlayerContainer = PlayerView()
    let playButton = UIButton()
    let closeButton = UIButton()
    let playheadSlider = UISlider()
    let positionLabel = UILabel()
    let durationLabel = UILabel()
    
    // MUX
    let playerName = "iOS KalturaPlayer"
    
    private var playerState: PlayerState = .idle {
        didSet {
            // Update player button icon depending on the state
            switch playerState {
            case .idle:
                self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            case .playing:
                self.playButton.setImage(UIImage(systemName: "pause"), for: .normal)
            case .paused:
                self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
            case .ended:
                self.playButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
        
        // Load PlayKit player
        self.kalturaPlayer = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
        self.setupKalturaPlayer()
        
        // Setup MUX
        self.setupMUX()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        MUXSDKStats.destroyPlayer(name: self.playerName)
        self.kalturaPlayer?.destroy()
    }
    
    func setupKalturaPlayer() {
        // Set PlayerView as the container for PlayKit Player variable
        self.kalturaPlayer?.view = self.kalturaPlayerContainer
        self.loadMediaKalturaPlayer()
        
        
        // Handle PlayKit events
        self.playerState = .idle
        let events = [
            PlayerEvent.pause,
            PlayerEvent.playing,
            PlayerEvent.ended,
            PlayerEvent.durationChanged
        ]
        
        // Update player state depending on the Playkit events
        self.kalturaPlayer?.addObserver(self, events: events) { [weak self] (event) in
            guard let self = self else { return }

            switch event {
            case is PlayerEvent.Playing:
                self.playerState = .playing
            case is PlayerEvent.Pause:
                self.playerState = .paused
            case is PlayerEvent.Ended:
                self.playerState = .ended
                // Test video change
                self.changeMediaKalturaPlayer()
            case is PlayerEvent.DurationChanged:
                // Observe PlayKit event durationChanged to update the maximum duration of the slider and duration label
                guard let duration = event.duration as? TimeInterval else {
                    return
                }
                
                self.playheadSlider.maximumValue = Float(duration)
                self.durationLabel.text = duration.formattedTimeDisplay
            default:
                break
            }
        }
        
        // Checks media progress to update the player slider and the current position label
        _ = self.kalturaPlayer?.addPeriodicObserver(
            interval: 0.2,
            observeOn: DispatchQueue.main,
            using: { [weak self] currentPosition in
                self?.playheadSlider.value = Float(currentPosition)
                self?.positionLabel.text = currentPosition.formattedTimeDisplay
            }
        )
    }
    
    func loadMediaKalturaPlayer() {
        let mediaConfig = createKalturaMediaConfig(
            contentURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
            entryId: "sintel"
        )
        
        // Prepare PlayKit player
        self.kalturaPlayer?.prepare(mediaConfig)
    }
    
    func changeMediaKalturaPlayer() {
        let mediaConfig = createKalturaMediaConfig(
            contentURL: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8",
            entryId: "bipbop_16x9"
        )
        
        // Call MUX videoChange before stop, because playkit stop will replace current item for nil
        self.MUXVideoChange()
        
        // Resets The Player And Prepares for Change Media
        self.kalturaPlayer?.stop()
        
        // Prepare PlayKit player
        self.kalturaPlayer?.prepare(mediaConfig)
        
        // Wait for `canPlay` event to play
        self.kalturaPlayer?.addObserver(self, events: [PlayerEvent.canPlay]) { event in
            self.kalturaPlayer?.play()
        }
    }
    
    func createKalturaMediaConfig(contentURL: String, entryId: String) -> MediaConfig {
        // Create PlayKit media source
        let source = PKMediaSource(entryId, contentUrl: URL(string: contentURL), drmData: nil, mediaFormat: .hls)
        
        // Setup PlayKit media entry
        let mediaEntry = PKMediaEntry(entryId, sources: [source])
        
        // Create PlayKit media config
        return MediaConfig(mediaEntry: mediaEntry)
    }
    
    func setupMUX() {
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "YOUR_ENV_KEY_HERE")
        playerData?.playerName = self.playerName
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Title Video Kaltura"
        videoData.videoId = "sintel"
        videoData.videoSeries = "animation"
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "my session id"
        
        let customData = MUXSDKCustomData()
        customData.customData1 = "Kaltura test"
        customData.customData2 = "Custom Data 2"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura DemoApp"
        
        let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData,
            viewerData: viewerData
        )
        
        guard let player = self.kalturaPlayer, let data = customerData else {
            return
        }
        
        MUXSDKStats.monitorPlayer(
            player: player,
            playerName: self.playerName,
            customerData: data
        )
    }
    
    func MUXVideoChange() {
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "YOUR_ENV_KEY_HERE")
        playerData?.playerName = self.playerName
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Apple Video Kaltura"
        videoData.videoId = "apple"
        videoData.videoSeries = "conference"
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "my second session id"
        
        let customData = MUXSDKCustomData()
        customData.customData1 = "Kaltura test video change"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura DemoApp"
        
        guard let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData,
            viewerData: viewerData
        ) else {
            return
        }
        
        MUXSDKStats.videoChangeForPlayer(name: self.playerName, customerData: customerData)
    }
    
    @objc func playButtonPressed() {
        guard let player = self.kalturaPlayer else {
            return
        }
        
        // Handle PlayKit events
        switch playerState {
        case .playing:
            player.pause()
        case .idle:
            player.play()
        case .paused:
            player.play()
        case .ended:
            player.seek(to: 0)
            player.play()
        }
    }
    
    @objc func closeButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func playheadValueChanged() {
        guard let player = self.kalturaPlayer else {
            return
        }
        
        if self.playerState == .ended && self.playheadSlider.value < self.playheadSlider.maximumValue {
            self.playerState = .paused
        }
        
        player.currentTime = TimeInterval(self.playheadSlider.value)
    }
}

extension PlayerViewController {
    enum PlayerState {
        case idle
        case playing
        case paused
        case ended
    }
}

extension PlayerViewController {
    func setupLayout() {
        self.view.backgroundColor = .black
        self.view.addSubview(self.kalturaPlayerContainer)
        
        // Constraint PlayKit player container to safe area layout guide
        self.kalturaPlayerContainer.translatesAutoresizingMaskIntoConstraints = false
        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.kalturaPlayerContainer.topAnchor.constraint(equalTo: guide.topAnchor),
            self.kalturaPlayerContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            self.kalturaPlayerContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            self.kalturaPlayerContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        
        let actionsContainer = UIStackView()
        actionsContainer.axis = .horizontal
        actionsContainer.spacing = 6.0
        actionsContainer.isLayoutMarginsRelativeArrangement = true
        actionsContainer.layoutMargins = UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
        actionsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.kalturaPlayerContainer.addSubview(actionsContainer)
        NSLayoutConstraint.activate([
            actionsContainer.bottomAnchor.constraint(equalTo: self.kalturaPlayerContainer.bottomAnchor),
            actionsContainer.heightAnchor.constraint(equalToConstant: 64.0),
            actionsContainer.leadingAnchor.constraint(equalTo: self.kalturaPlayerContainer.leadingAnchor),
            actionsContainer.trailingAnchor.constraint(equalTo: self.kalturaPlayerContainer.trailingAnchor)
        ])
        
        // Add play/pause button
        self.playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        self.playButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 4, bottom: 20, right: 4)
        self.playButton.contentHorizontalAlignment = .fill
        self.playButton.contentVerticalAlignment = .fill
        actionsContainer.addArrangedSubview(self.playButton)
        NSLayoutConstraint.activate([
            self.playButton.widthAnchor.constraint(equalToConstant: 28.0)
        ])
        
        self.positionLabel.textColor = .lightText
        self.positionLabel.text = TimeInterval.zero.formattedTimeDisplay
        actionsContainer.addArrangedSubview(self.positionLabel)
        
        self.playheadSlider.addTarget(self, action: #selector(self.playheadValueChanged), for: .valueChanged)
        actionsContainer.addArrangedSubview(self.playheadSlider)
        
        self.durationLabel.textColor = .lightText
        self.durationLabel.text = TimeInterval.zero.formattedTimeDisplay
        actionsContainer.addArrangedSubview(self.durationLabel)
        
        // Add close button
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .touchUpInside)
        self.closeButton.setImage(UIImage(systemName: "xmark.square"), for: .normal)
        self.closeButton.contentVerticalAlignment = .fill
        self.closeButton.contentHorizontalAlignment = .fill
        self.kalturaPlayerContainer.addSubview(self.closeButton)
        NSLayoutConstraint.activate([
            self.closeButton.heightAnchor.constraint(equalToConstant: 32.0),
            self.closeButton.widthAnchor.constraint(equalToConstant: 32.0),
            self.closeButton.trailingAnchor.constraint(equalTo: self.kalturaPlayerContainer.trailingAnchor, constant: -24.0),
            self.closeButton.topAnchor.constraint(equalTo: self.kalturaPlayerContainer.topAnchor, constant: 24.0)
        ])
    }
}
