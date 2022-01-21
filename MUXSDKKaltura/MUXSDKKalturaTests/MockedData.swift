//
//  MockedData.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 9/11/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore
import PlayKit
@testable import MUXSDKKaltura

enum MockedData {
    static let playerName = "Test Player"
    
    static var customerData: MUXSDKCustomerData? {
        let playerName = Self.playerName
        
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "ENV_KEY")
        playerData?.playerName = playerName
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Video Title"
        videoData.videoId = "videoId"
        videoData.videoSeries = "series"
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "session id"
        
        let customData = MUXSDKCustomData()
        customData.customData1 = "Custom Data 1"
        customData.customData2 = "Custom Data 2"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura Tests"
        
        return MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData,
            viewerData: viewerData
        )
    }
    
    static func buildCustomerData(
        playerData: MUXSDKCustomerPlayerData? = nil,
        videoData: MUXSDKCustomerVideoData? = nil,
        viewData: MUXSDKCustomerViewData? = nil,
        customData: MUXSDKCustomData? = nil,
        viewerData: MUXSDKCustomerViewerData? = nil
    ) -> MUXSDKCustomerData? {
        return MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData ,
            viewerData: viewerData
        )
    }
    
    static let player = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
    
    static let dispatcher = MockedDispatcher.shared
    
    static let bindingManager = MUXSDKPlayerBindingManager(dispatcher: dispatcher)
    
    static let binding = MUXSDKPlayerBinding(
        name: playerName,
        software: "KalturaPlayer",
        automaticErrorTracking: true,
        playDispatchDelegate: bindingManager,
        dispatcher: dispatcher
    )
}
