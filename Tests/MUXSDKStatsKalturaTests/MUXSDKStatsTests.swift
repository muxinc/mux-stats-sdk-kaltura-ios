//
//  MUXSDKStatsTests.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 9/11/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKStatsKaltura
import MuxCore
import PlayKit

class MUXSDKStatsTests: XCTestCase {
    override func setUp() {
        super.setUp()

        MUXSDKStats.isTesting = true

        MockedData.dispatcher.destroyPlayer(MockedData.playerName)
        MockedData.dispatcher.resetDispatchedEvents()
    }

    func testSetCustomerDataWithVideoDataViewerData() throws {
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
        try assertDispatchedCustomerDataEventsMatch(
            expectedCustomerVideoData: expectedCustomerVideoData,
            at: 3
        )
        assertDispatchedCustomerViewerDataEventsAtIndex(
            index: 1,
            expectedCustomerViewerData: expectedCustomerViewerData
        )

        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
    
    func testSetCustomerDataWithPlayerDataViewDataAndViewerData() throws {
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
        
        try assertDispatchedCustomerDataEventsMatch(
            expectedCustomerPlayerData: expectedCustomerPlayerData,
            expectedCustomerViewData: expectedCustomerViewData,
            at: 3
        )
        self.assertDispatchedCustomerViewerDataEventsAtIndex(
            index: 1,
            expectedCustomerViewerData: expectedCustomerViewerData
        )

        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
    
    func testSetCustomerDataWithViewerData() throws {
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
    
        self.assertDispatchedCustomerViewerDataEventsAtIndex(
            index: 1,
            expectedCustomerViewerData: expectedCustomerViewerData
        )

        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
    
    func testMonitorPlayer() throws {
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
        
        try assertDispatchedCustomerDataEventsMatch(
            expectedCustomerVideoData: expectedCustomerVideoData,
            expectedCustomerPlayerData: expectedCustomerPlayerData,
            expectedCustomerViewData: expectedCustomerViewData,
            expectedCustomData: expectedCustomData,
            at: 1
        )
        self.assertDispatchedCustomerViewerDataEventsAtIndex(
            index: 0,
            expectedCustomerViewerData: expectedViewerData
        )

        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
    
    func testDestroyPlayer() throws {
        guard
            let customerData = MockedData.customerData
        else {
            XCTFail("Customer data not found")
            return
        }
       
        // Start monitor player to emit events
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
       
        // Remove observers on the player
        MUXSDKStats.destroyPlayer(name: MockedData.playerName)

        let expectedEvents = [
            MUXSDKPlaybackEventViewInitEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventPlayerReadyEventType,
            MUXSDKPlaybackEventViewEndEventType
        ]

        // Assert expected events
        self.assertDispatchedEventTypesMatch(
            expectedEventTypes: expectedEvents,
            for: MockedData.playerName
        )

        // Clean player instance after test
        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
       
    func testClearsCustomerMetadataOnDestroy() throws {
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Video Title"
        videoData.videoId = "videoId"
        videoData.videoSeries = "series"

        let customData = MUXSDKCustomData()
        customData.customData1 = "Custom Data 1"
        customData.customData2 = "Custom Data 2"

        let updatedVideoData = MUXSDKCustomerVideoData()
        updatedVideoData.videoTitle = "Video Title Version Clears Customer Metadata On Destroy"
        updatedVideoData.videoId = "videoId Version Clears Customer Metadata On Destroy"
        updatedVideoData.videoSeries = "series Version Clears Customer Metadata On Destroy"

        let baseCustomerData = MockedData.buildCustomerData(videoData: videoData, customData: customData)
        let newCustomerData = MockedData.buildCustomerData(videoData: updatedVideoData)
        guard
            let customerData = baseCustomerData,
            let customerDataUpdated = newCustomerData
        else {
            XCTFail("Customer data not found")
            return
        }

        // Start monitor player to emit events
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)

        var expectedEvents = [
            MUXSDKPlaybackEventViewInitEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventPlayerReadyEventType
        ]
        let expectedCustomerVideoData: [String : Any] = [
            "vtt" : "Video Title",
            "vid" : "videoId",
            "vsr" : "series"
        ]

        let expectedCustomData: [String : Any] = [
            "c1" : "Custom Data 1",
            "c2" : "Custom Data 2"
        ]

        // Assert expected events
        self.assertDispatchedEventTypesMatch(
            expectedEventTypes: expectedEvents,
            for: MockedData.playerName
        )

        // Assert expected data
        try assertDispatchedCustomerDataEventsMatch(
            expectedCustomerVideoData: expectedCustomerVideoData,
            expectedCustomData: expectedCustomData,
            at: 1
        )

        // Remove observers on the player
        MUXSDKStats.destroyPlayer(name: MockedData.playerName)

        // Update customer data
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerDataUpdated)

        // Start monitor player to emit events
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerDataUpdated)

        expectedEvents = [
            MUXSDKPlaybackEventViewInitEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventPlayerReadyEventType,
            MUXSDKPlaybackEventViewEndEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventViewInitEventType,
            MUXSDKDataEventType,
            MUXSDKPlaybackEventPlayerReadyEventType
        ]
        let expectedCustomerUpdatedVideoData = [
            "vtt" : "Video Title Version Clears Customer Metadata On Destroy",
            "vid" : "videoId Version Clears Customer Metadata On Destroy",
            "vsr" : "series Version Clears Customer Metadata On Destroy"
        ]

        // Assert expected events
        self.assertDispatchedEventTypesMatch(
            expectedEventTypes: expectedEvents,
            for: MockedData.playerName
        )

        // Assert expected updated data
        try assertDispatchedCustomerDataEventsMatch(
            expectedCustomerVideoData: expectedCustomerUpdatedVideoData,
            at: 4
        )

        // Clean player instance after test
        MUXSDKStats.destroyPlayer(name: MockedData.playerName)
    }
}
