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
            SDKLogger.log("MUXSDK-ERROR - Mux failed to find the Kaltura Playkit Player current item.")
            return nil
        }
        
        return currentItem
    }
    
    var sourceDimensions: CGSize {
        guard
            let currentItem = self.currentItem
        else {
            return .zero
        }
        
        for track in currentItem.tracks {
            // loop until first track with video description
            if let formatDescriptions = track.assetTrack?.formatDescriptions as? [CMFormatDescription] {
                for description in formatDescriptions {
                    var isVideoDescription: Bool {
                        // Remove the conditional if we drop support for iOS < 13.0
                        if #available(iOS 13.0, tvOS 13.0, *) {
                            return description.mediaType == .video
                        } else {
                            return CMFormatDescriptionGetMediaType(description) == kCMMediaType_Video
                        }
                    }
                    
                    if isVideoDescription {
                        // Map video dimensions in pixels
                        var dimensions: CMVideoDimensions {
                            // Remove the conditional if we drop support for iOS < 13.0
                            if #available(iOS 13.0, tvOS 13.0, *) {
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
