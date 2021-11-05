//
//  VideoData.swift
//  KalturaNetKit
//
//  Created by Stephanie Zuñiga on 1/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import CoreMedia

struct VideoData {
    var size = CGSize.zero
    var duration = TimeInterval.zero
    var isLive = false
    var url: String? = nil
    var seeking = false
    var started = false
    var lastAdvertisedBitrate: Double = 0.0
    var lastDispatchedAdvertisedBitrate: Double = 0.0
    var lastSeekingPlayheadTimeMs: Double = 0.0
    var sourceDimensionsHaveChanged = false
    var lastDispatchedVideoSize = CGSize.zero
    var playerErrors = [Error]()
    var lastPlayheadTimeMsOnPause: Double = 0.0
    var lastTransferEventCount: Int = 0
    var lastTransferDuration: Double = 0.0
    var lastTransferredBytes: Int64 = 0
    var hasUpdates = false // Only to keep track of manual updates for check in updateVideoData
}
