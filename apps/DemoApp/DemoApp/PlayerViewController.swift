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
import MediaPlayer

class PlayerViewController: UIViewController {
    var kalturaPlayer: Player?
    let kalturaPlayerContainer = PlayerView()
    let playButton = UIButton()
    let closeButton = UIButton()
    let playheadSlider = UIProgressView()
    let positionLabel = UILabel()
    let durationLabel = UILabel()
    let airplayButton = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    var duration: TimeInterval = 0.0
    
    // MUX
    let playerName = "iOS KalturaPlayer"
    let environmentKey = "YOUR_ENV_KEY_HERE"
    
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
//        self.testProgramChange()
//        self.testUpdateCustomerData()
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
                
                self.duration = duration
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
                guard let self = self else { return }
                self.playheadSlider.setProgress(Float(currentPosition/self.duration), animated: true)
                self.positionLabel.text = currentPosition.formattedTimeDisplay
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
        let playerData = MUXSDKCustomerPlayerData(environmentKey: self.environmentKey)
        playerData?.playerName = self.playerName
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Title Video Kaltura"
        videoData.videoId = "sintel"
        
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
        let playerData = MUXSDKCustomerPlayerData(environmentKey: self.environmentKey)
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
    
    @objc func MUXProgramChange() {
        let playerData = MUXSDKCustomerPlayerData(environmentKey: self.environmentKey)
        playerData?.playerName = self.playerName
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Program Change Title Video Kaltura"
        videoData.videoId = "Program Change sintel"
        videoData.videoSeries = "Program Change animation"
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "Program Change my session id"
        
        let customData = MUXSDKCustomData()
        customData.customData1 = "Program Change Kaltura test"
        customData.customData2 = "Program Change Custom Data 2"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "Program Change MUX Kaltura DemoApp"
        
        guard let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData,
            viewerData: viewerData
        ) else {
            return
        }
        
        MUXSDKStats.programChangeForPlayer(name: self.playerName, customerData: customerData)
    }
    
    func testProgramChange() {
        // Test MUX Program Change
        // Schedule program change event at 30s
        Timer.scheduledTimer(
            timeInterval: 30.0,
            target: self,
            selector: #selector(self.MUXProgramChange),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc func MUXSetCustomerData() {
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoSeries = "Data Update animation"
        
        guard let customerData = MUXSDKCustomerData(
            customerPlayerData: nil,
            videoData: videoData,
            viewData: nil,
            customData: nil,
            viewerData: nil
        ) else {
            return
        }
        
        MUXSDKStats.setCustomerDataForPlayer(name: self.playerName, customerData: customerData)
    }
    
    func testUpdateCustomerData() {
        // Test MUX Data Update
        // Schedule data update at 15s
        Timer.scheduledTimer(
            timeInterval: 15.0,
            target: self,
            selector: #selector(self.MUXSetCustomerData),
            userInfo: nil,
            repeats: false
        )
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
    
    @objc func seekForward() {
        let newPosition = (self.kalturaPlayer?.currentTime ?? 0).advanced(by: 15)
        let position = newPosition <= self.duration ? newPosition : self.duration
        self.kalturaPlayer?.seek(to: position)
        
        if self.playerState == .ended && self.playheadSlider.progress < 1 {
            self.playerState = .paused
        }
    }
    
    @objc func seekBackward() {
        let newPosition = (self.kalturaPlayer?.currentTime ?? 0).advanced(by: -15)
        let position = newPosition >= 0 ? newPosition : 0
        self.kalturaPlayer?.seek(to: position)
    }
    
    @objc func closeButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func playheadValueChanged(gestureRecognizer: UIPanGestureRecognizer) {
        guard let player = self.kalturaPlayer else {
            return
        }
        
        let gesturePoint = gestureRecognizer.location(in: self.playheadSlider)
        switch gestureRecognizer.state {
        case .changed:
            let progress = gesturePoint.x/self.playheadSlider.frame.width
            self.playheadSlider.setProgress(Float(progress), animated: true)
            
            if self.playerState == .ended && self.playheadSlider.progress < 1 {
                self.playerState = .paused
            }
            
            player.seek(to: Double(self.playheadSlider.progress) * self.duration)
        default:
            return
        }
    }
    
    // MARK: Orientation Changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        #if os(iOS)
        let orientation = UIDevice.current.orientation.isLandscape ? MUXSDKViewOrientation.landscape : MUXSDKViewOrientation.portrait
        MUXSDKStats.orientationChangeForPlayer(name: self.playerName, orientation: orientation)
        #endif
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
        actionsContainer.axis = .vertical
        actionsContainer.isLayoutMarginsRelativeArrangement = true
        actionsContainer.layoutMargins = UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
        actionsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.kalturaPlayerContainer.addSubview(actionsContainer)
        NSLayoutConstraint.activate([
            actionsContainer.bottomAnchor.constraint(equalTo: self.kalturaPlayerContainer.bottomAnchor),
            actionsContainer.leadingAnchor.constraint(equalTo: self.kalturaPlayerContainer.leadingAnchor),
            actionsContainer.trailingAnchor.constraint(equalTo: self.kalturaPlayerContainer.trailingAnchor)
        ])
        
        // Add airplay button
        self.airplayButton.showsVolumeSlider = false
        NSLayoutConstraint.activate([
            self.airplayButton.widthAnchor.constraint(equalToConstant: 44.0),
            self.airplayButton.heightAnchor.constraint(equalToConstant: 44.0)
        ])
        
        let airplayRowStack = UIStackView()
        airplayRowStack.axis = .horizontal
        airplayRowStack.addArrangedSubview(UIView())
        airplayRowStack.addArrangedSubview(airplayButton)
        actionsContainer.addArrangedSubview(airplayRowStack)
        
        let actionsRowStack = UIStackView()
        actionsRowStack.axis = .horizontal
        actionsRowStack.alignment = .center
        actionsRowStack.spacing = 6.0
        actionsContainer.addArrangedSubview(actionsRowStack)
        NSLayoutConstraint.activate([
            actionsRowStack.heightAnchor.constraint(equalToConstant: 44.0)
        ])
        
        // Add play/pause button
        self.playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .primaryActionTriggered)
        self.playButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
        self.playButton.contentHorizontalAlignment = .fill
        self.playButton.contentVerticalAlignment = .fill
        actionsRowStack.addArrangedSubview(self.playButton)
        NSLayoutConstraint.activate([
            self.playButton.widthAnchor.constraint(equalToConstant: 28.0)
        ])
        
        self.positionLabel.textColor = .lightGray
        self.positionLabel.text = TimeInterval.zero.formattedTimeDisplay
        actionsRowStack.addArrangedSubview(self.positionLabel)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.playheadValueChanged))
        self.playheadSlider.addGestureRecognizer(panGesture)
        actionsRowStack.addArrangedSubview(self.playheadSlider)
        NSLayoutConstraint.activate([
            self.playheadSlider.heightAnchor.constraint(equalToConstant: 16.0)
        ])
        
        self.durationLabel.textColor = .lightGray
        self.durationLabel.text = TimeInterval.zero.formattedTimeDisplay
        actionsRowStack.addArrangedSubview(self.durationLabel)
        
        guard UIDevice.current.userInterfaceIdiom == .tv else {
            // Add close button
            self.closeButton.translatesAutoresizingMaskIntoConstraints = false
            self.closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .primaryActionTriggered)
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
            return
        }
        
        // Apple tv remote gestures
        
        // Handle Play/Pause tap
        let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playButtonPressed))
        playPauseRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        self.view.addGestureRecognizer(playPauseRecognizer)
        
        // Handle Right tap
        let rightTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.seekForward))
        rightTapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)];
        self.view.addGestureRecognizer(rightTapRecognizer)
        
        // Handle Left tap
        let leftTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.seekBackward))
        leftTapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)];
        self.view.addGestureRecognizer(leftTapRecognizer)
        
        // Handle right swipe
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.seekForward))
        swipeRightRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRightRecognizer)
        
        // Handle left swipe
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.seekBackward))
        swipeLeftRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeLeftRecognizer)
    }
}
