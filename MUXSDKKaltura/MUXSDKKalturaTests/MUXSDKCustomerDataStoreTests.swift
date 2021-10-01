//
//  MUXSDKKalturaTests.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 20/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKKaltura
import MuxCore

class MUXSDKCustomerDataStoreTests: XCTestCase {
    
    func testSetCustomerDataStore() {
        let dataStore = MUXSDKCustomerDataStore()
        
        guard let customerData = Self.customerData else {
            XCTFail("Customer data not found")
            return
        }
        
        dataStore.setData(customerData, forPlayerName: Self.playerName)
        
        let expectedData = dataStore.dataForPlayerName(Self.playerName)
        
        // Test customer player data
        let expectedPlayerData = expectedData?.customerPlayerData
        XCTAssertEqual(expectedPlayerData?.playerName, "Test Player")
        
        // Test customer video data
        let expectedVideoData = expectedData?.customerVideoData
        XCTAssertEqual(expectedVideoData?.videoTitle, "Video Title")
        XCTAssertEqual(expectedVideoData?.videoId, "videoId")
        XCTAssertEqual(expectedVideoData?.videoSeries, "series")
        
        // Test customer view data
        let expectedViewData = expectedData?.customerViewData
        XCTAssertEqual(expectedViewData?.viewSessionId, "session id")
        
        // Test customer viewer data
        let expectedViewerData = expectedData?.customerViewerData
        XCTAssertEqual(expectedViewerData?.viewerApplicationName, "MUX Kaltura Tests")
        
        // Test custom data
        let expectedCustomData = expectedData?.customData
        XCTAssertEqual(expectedCustomData?.customData1, "Custom Data 1")
        XCTAssertEqual(expectedCustomData?.customData2, "Custom Data 2")
    }

    func testUpdateCustomerDataStore() {
        let dataStore = MUXSDKCustomerDataStore()
        
        guard let customerData = Self.customerData else {
            XCTFail("Customer data not found")
            return
        }
        
        // Set initial data
        dataStore.setData(customerData, forPlayerName: Self.playerName)
        
        // Test initial custom data
        let expectedCustomData = dataStore.dataForPlayerName(Self.playerName)?.customData
        XCTAssertEqual(expectedCustomData?.customData1, "Custom Data 1")
        XCTAssertEqual(expectedCustomData?.customData2, "Custom Data 2")
        
        // Update custom data
        let newCustomData = MUXSDKCustomData()
        newCustomData.customData1 = "New Custom Data 1"
        dataStore.updateData(customData: newCustomData, forPlayerName: Self.playerName)
        
        // Test updated custom data
        let updatedData = dataStore.dataForPlayerName(Self.playerName)
        let updatedCustomData = updatedData?.customData
        XCTAssertEqual(updatedCustomData?.customData1, "New Custom Data 1")
        
        // Test customer player data didn't change
        let expectedPlayerData = updatedData?.customerPlayerData
        XCTAssertEqual(expectedPlayerData?.playerName, "Test Player")
        
        // Test customer video data didn't change
        let expectedVideoData = updatedData?.customerVideoData
        XCTAssertEqual(expectedVideoData?.videoTitle, "Video Title")
        XCTAssertEqual(expectedVideoData?.videoId, "videoId")
        XCTAssertEqual(expectedVideoData?.videoSeries, "series")
    }

}

extension MUXSDKCustomerDataStoreTests {
    static let playerName = "Test Player"
    static var customerData: MUXSDKCustomerData? {
        let playerName = playerName
        
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
}
