//
//  MUXSDKStatsTests.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 9/11/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKKaltura
import MuxCore
import PlayKit

class MUXSDKStatsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        MockedData.dispatcher.resetDispatchedEvents()
        MockedData.dispatcher.destroyPlayer(MockedData.playerName)
    }

    func testSetCustomerDataWithVideoDataViewerData() {
        ///Test for setting customer data with Video data and viewer data.

        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Video Title Version Video Data and Viewer Data"
        videoData.videoId = "videoId Version Video Data and Viewer Data"
        videoData.videoSeries = "series Version Video Data and Viewer Data"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura Tests Version Video Data and Viewer Data"
        
        let newCustomerData = MockedData.buildCustomerData(videoData: videoData, viewerData: viewerData)
        guard
            let customerData = MockedData.customerData,
            let customerDataUpdated = newCustomerData
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerDataUpdated)
        
        let expectedCustomerVideoData: [String : Any] = [
            "vtt" : "Video Title Version Video Data and Viewer Data",
            "vid" : "videoId Version Video Data and Viewer Data",
            "vsr" : "series Version Video Data and Viewer Data"
        ]
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version Video Data and Viewer Data"
        self.assertDispatchedCustomerDataEventsMatch(expectedCustomerVideoData: expectedCustomerVideoData, at: 4)
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
    
    func testSetCustomerDataWithPlayerDataViewDataAndViewerData() {
        ///Test for setting customer data with Player Data, View data and viewer data.
        
        let playerName = MockedData.playerName
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "ENV_KEY_PlayerData_ViewData_ViewerData")
        playerData?.playerName = playerName
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "session id Version PlayerData ViewData and ViewerData"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura Tests Version PlayerData ViewData and ViewerData"
        
        let newCustomerData = MockedData.buildCustomerData(
            playerData: playerData,
            viewData: viewData,
            viewerData: viewerData)
        
        guard
            let customerData = MockedData.customerData,
            let customerDataUpdated = newCustomerData
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerDataUpdated)
        
        let expectedCustomerPlayerData: [String : Any] = [
            "ake" : "ENV_KEY_PlayerData_ViewData_ViewerData",
            "pnm" : "Test Player"
        ]

        let expectedCustomerViewData: [String : Any] = [
            "xseid" : "session id Version PlayerData ViewData and ViewerData"
        ]
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version PlayerData ViewData and ViewerData"
        
        self.assertDispatchedCustomerDataEventsMatch(
            expectedCustomerPlayerData: expectedCustomerPlayerData,
            expectedCustomerViewData: expectedCustomerViewData,
            at: 4
        )
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
    
    func testSetCustomerDataWithViewerData() {
        ///Test for setting customer data with viewer data.
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Kaltura Tests Version Viewer Data"
        
        let newCustomerData = MockedData.buildCustomerData(viewerData: viewerData)
        guard
            let customerData = MockedData.customerData,
            let customerDataUpdated = newCustomerData
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerDataUpdated)
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version Viewer Data"
    
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
    
    func testMonitorPlayer() {
        guard let customerData = MockedData.customerData else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        let expectedEvents = [
            MUXSDKPlaybackEventViewInitEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventPlayerReadyEventType
        ]
        
        self.assertDispatchedEventTypesMatch(
            expectedEventTypes: expectedEvents,
            for: MockedData.playerName
        )
        
        let expectedCustomerVideoData: [String : Any] = [
            "vtt" : "Video Title",
            "vid" : "videoId",
            "vsr" : "series"
        ]
        
        let expectedCustomerPlayerData: [String : Any] = [
            "ake" : "ENV_KEY",
            "pnm" : "Test Player"
        ]
        
        let expectedCustomerViewData: [String : Any] = [
            "xseid" : "session id"
        ]
        
        let expectedCustomData: [String : Any] = [
            "c1" : "Custom Data 1",
            "c2" : "Custom Data 2"
        ]
        
        let expectedViewerData = "MUX Kaltura Tests"
        
        self.assertDispatchedCustomerDataEventsMatch(
            expectedCustomerVideoData: expectedCustomerVideoData,
            expectedCustomerPlayerData: expectedCustomerPlayerData,
            expectedCustomerViewData: expectedCustomerViewData,
            expectedCustomData: expectedCustomData,
            at: 1
        )
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 0, expectedCustomerViewerData: expectedViewerData)
    }
}
