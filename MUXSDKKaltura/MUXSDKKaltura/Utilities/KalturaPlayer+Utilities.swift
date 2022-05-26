//
//  KalturaPlayer+Utilities.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 14/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import PlayKit
import AVFoundation

extension PlayKit.Player {
    var currentItem: AVPlayerItem? {
        guard
            let playerLayer = self.view?.layer as? AVPlayerLayer,
            let currentItem = playerLayer.player?.currentItem
        else {
            print("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player current item.")
            return nil
        }
        
        return currentItem
    }
}
