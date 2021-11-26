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
        
        guard let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents.last(where: { $0.playerId == MockedData.playerName })?.event as? MUXSDKDataEvent else {
            XCTFail("MUXSDKDataEvent not found")
            return
        }
        
        XCTAssertNil(lastDispatchedEvent.customerViewData)
        XCTAssertNil(lastDispatchedEvent.customerPlayerData)
        XCTAssertNil(lastDispatchedEvent.customData)
        
        guard let customerVideoData = lastDispatchedEvent.customerVideoData else {
            XCTFail("Customer video data for MUXSDKDataEvent not found")
            return
        }
                                                             
        XCTAssertTrue(NSDictionary(dictionary: customerVideoData.toQuery()).isEqual(to: expectedCustomerVideoData))
        
        guard let lastGlobalDispatchedEvent = MockedData.dispatcher.dispatchedGlobalDataEvents.last else {
            XCTFail("MUXSDKDataEvent not found")
            return
        }
        
        guard let viewerData = lastGlobalDispatchedEvent.viewerData else {
            XCTFail("Viewer data for MUXSDKDataEvent not found")
            return
        }

        XCTAssertEqual(viewerData.viewerApplicationName, "MUX Kaltura Tests Version 2")
    }
}
