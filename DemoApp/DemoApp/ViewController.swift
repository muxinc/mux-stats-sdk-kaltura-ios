//
//  ViewController.swift
//  DemoApp
//
//  Created by Stephanie Zuñiga on 20/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import UIKit
import PlayKit

class ViewController: UIViewController {
    var player: Player?
    let playerContainer = PlayerView()
    let playButton = UIButton()
    let playheadSlider = UISlider()
    let positionLabel = UILabel()
    let durationLabel = UILabel()
    
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
        self.player = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
        self.setupPlayer()
    }
    
    func setupPlayer() {
        // Set PlayerView as the container for PlayKit Player variable
        self.player?.view = self.playerContainer
        self.loadMedia()
        
        
        // Handle PlayKit events
        self.playerState = .idle
        let events = [
            PlayerEvent.pause,
            PlayerEvent.playing,
            PlayerEvent.ended
        ]
        
        // Update player state depending on the Playkit events
        self.player?.addObserver(self, events: events) { [weak self] (event) in
            guard let self = self else { return }

            switch event {
            case is PlayerEvent.Playing:
                self.playerState = .playing
            case is PlayerEvent.Pause:
                self.playerState = .paused
            case is PlayerEvent.Ended:
                self.playerState = .ended
            default:
                break
            }
        }
        
        // Checks media progress to update the player slider and the current position label
        _ = self.player?.addPeriodicObserver(
            interval: 0.2,
            observeOn: DispatchQueue.main,
            using: { [weak self] currentPosition in
                self?.playheadSlider.value = Float(currentPosition)
                self?.positionLabel.text = currentPosition.formattedTimeDisplay
            }
        )
        
        // Observe PlayKit event durationChanged to update the maximum duration of the slider and duration label
        self.player?.addObserver(
            self,
            events: [PlayerEvent.durationChanged],
            block: { [weak self] event in
                guard
                    let self = self,
                    let durationEvent = event as? PlayerEvent.DurationChanged,
                    let duration = durationEvent.duration as? TimeInterval
                else {
                    return
                }
                
                self.playheadSlider.maximumValue = Float(duration)
                self.durationLabel.text = duration.formattedTimeDisplay
            }
        )
    }
    
    func loadMedia() {
        let contentURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
        let entryId = "sintel"
        
        // Create PlayKit media source
        let source = PKMediaSource(entryId, contentUrl: URL(string: contentURL), drmData: nil, mediaFormat: .hls)
        
        // Setup PlayKit media entry
        let mediaEntry = PKMediaEntry(entryId, sources: [source])
        
        // Create PlayKit media config
        let mediaConfig = MediaConfig(mediaEntry: mediaEntry)
        
        // Prepare PlayKit player
        self.player!.prepare(mediaConfig)
    }
    
    @objc func playButtonPressed() {
        guard let player = self.player else {
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
    
    @objc func playheadValueChanged() {
        guard let player = self.player else {
            return
        }
        
        if self.playerState == .ended && self.playheadSlider.value < self.playheadSlider.maximumValue {
            self.playerState = .paused
        }
        
        player.currentTime = TimeInterval(self.playheadSlider.value)
    }
}

extension ViewController {
    enum PlayerState {
        case idle
        case playing
        case paused
        case ended
    }
}

extension ViewController {
    func setupLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.playerContainer)
        
        // Constraint PlayKit player container to safe area layout guide
        self.playerContainer.translatesAutoresizingMaskIntoConstraints = false
        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.playerContainer.topAnchor.constraint(equalTo: guide.topAnchor),
            self.playerContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            self.playerContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            self.playerContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        
        let actionsContainer = UIStackView()
        actionsContainer.axis = .horizontal
        actionsContainer.spacing = 6.0
        actionsContainer.isLayoutMarginsRelativeArrangement = true
        actionsContainer.layoutMargins = UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
        actionsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.playerContainer.addSubview(actionsContainer)
        NSLayoutConstraint.activate([
            actionsContainer.bottomAnchor.constraint(equalTo: self.playerContainer.bottomAnchor),
            actionsContainer.heightAnchor.constraint(equalToConstant: 64.0),
            actionsContainer.leadingAnchor.constraint(equalTo: self.playerContainer.leadingAnchor),
            actionsContainer.trailingAnchor.constraint(equalTo: self.playerContainer.trailingAnchor)
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
    }
}
