//
//  MUXSDKKalturaTests.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 20/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKStatsKaltura
import MuxCore

class MUXSDKCustomerDataStoreTests: XCTestCase {
    
    func testSetCustomerDataStore() {
        let dataStore = MUXSDKCustomerDataStore()
        
        guard let customerData = MockedData.customerData else {
            XCTFail("Customer data not found")
            return
        }
        
        dataStore.setData(customerData, forPlayerName: MockedData.playerName)
        
        let expectedData = dataStore.dataForPlayerName(MockedData.playerName)
        
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
        
        guard let customerData = MockedData.customerData else {
            XCTFail("Customer data not found")
            return
        }
        
        // Set initial data
        dataStore.setData(customerData, forPlayerName: MockedData.playerName)
        
        // Test initial custom data
        let expectedCustomData = dataStore.dataForPlayerName(MockedData.playerName)?.customData
        XCTAssertEqual(expectedCustomData?.customData1, "Custom Data 1")
        XCTAssertEqual(expectedCustomData?.customData2, "Custom Data 2")
        
        // Update custom data
        let newCustomData = MUXSDKCustomData()
        newCustomData.customData1 = "New Custom Data 1"
        
        let newCustomerData = MUXSDKCustomerData()
        newCustomerData.customData = newCustomData
        
        dataStore.updateData(newCustomerData, forPlayerName: MockedData.playerName)
        
        // Test updated custom data
        let updatedData = dataStore.dataForPlayerName(MockedData.playerName)
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
