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

    func testSetCustomerData() {
        guard
            let customerData = MockedData.customerData,
            let customerData2 = MockedData.customerData2
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerData2)
        
        let expectedCustomerVideoData: [String : Any] = [
            "vtt" : "Video Title Version 2",
            "vid" : "videoId Version 2",
            "vsr" : "series Version 2"
        ]
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version 2"
        
        self.assertDispatchedCustomerDataEventsMatch(expectedCustomerVideoData: expectedCustomerVideoData, at: 3)
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
    
    func testSetCustomerDataWithPlayerDataViewDataAndNilVideoData() {
        guard
            let customerData = MockedData.customerData,
            let customerData3 = MockedData.customerData3
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerData3)
        
        let expectedCustomerPlayerData: [String : Any] = [
            "ake" : "ENV_KEY_3",
            "pnm" : "Test Player"
        ]

        let expectedCustomerViewData: [String : Any] = [
            "xseid" : "session id 3"
        ]
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version 3"
        
        self.assertDispatchedCustomerDataEventsMatch(
            expectedCustomerPlayerData: expectedCustomerPlayerData,
            expectedCustomerViewData: expectedCustomerViewData,
            at: 4
        )
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
    
    func testSetCustomerDataWithViewerData() {
        guard
            let customerData = MockedData.customerData,
            let customerData4 = MockedData.customerData4
        else {
            XCTFail("Customer data not found")
            return
        }
        
        MUXSDKStats.monitorPlayer(player: MockedData.player, playerName: MockedData.playerName, customerData: customerData)
        MUXSDKStats.setCustomerDataForPlayer(name: MockedData.playerName, customerData: customerData4)
        
        let expectedCustomerViewerData = "MUX Kaltura Tests Version 4"
    
        self.assertDispatchedCustomerViewerDataEventsAtIndex(index: 1, expectedCustomerViewerData: expectedCustomerViewerData)
    }
}
