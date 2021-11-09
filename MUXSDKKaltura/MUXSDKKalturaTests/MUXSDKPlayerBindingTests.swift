//
//  MUXSDKPlayerBindingTests.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 27/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKKaltura
import MuxCore
import PlayKit

class MUXSDKPlayerBindingTests: XCTestCase {
    
    func testBuildBandwidthMetricData() {
        let data = MockedData.binding.buildBandwidthMetricData(
            requestCompletedTime: 1635368919.595179,
            requestStartSecs: 1635368918.7956688,
            numberOfBytesTransferred: 54896,
            url: "https://bitdash-a.akamaihd.net/content/sintel/hls/video"
        )
        
        let expectedData: [String : Any] = [
            "qrpen": "1635368919595",
            "qst": "1635368918795.669",
            "qbyld": "54896",
            "qty": "media",
            "qhn": "bitdash-a.akamaihd.net"
        ]
        
        XCTAssertTrue(NSDictionary(dictionary: data.toQuery()).isEqual(to: expectedData))
    }
    
    func testDispatchPortraitOrientationChange() {
        MockedData.binding.attachPlayer(MockedData.player)
        
        MockedData.binding.dispatchOrientationChange(orientation: .portrait)
        
        let expectedData: [String : Any] = [
            "xdvor": [
                "x": 0,
                "y": 0,
                "z": 90
            ]
        ]
        
        guard let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents.last(where: { $0.playerId == MockedData.playerName })?.event as? MUXSDKOrientationChangeEvent else {
            XCTFail("MUXSDKOrientationChangeEvent not found")
            return
        }
        
        guard let viewData = lastDispatchedEvent.viewData else {
            XCTFail("View data for MUXSDKOrientationChangeEvent not found")
            return
        }
                                                             
        XCTAssertTrue(NSDictionary(dictionary: viewData.toQuery()).isEqual(to: expectedData))
    }
    
    func testDispatchLandscapeOrientationChange() {
        MockedData.binding.attachPlayer(MockedData.player)
        
        MockedData.binding.dispatchOrientationChange(orientation: .landscape)
        
        let expectedData: [String : Any] = [
            "xdvor": [
                "x": 0,
                "y": 0,
                "z": 0
            ]
        ]
        
        guard let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents.last(where: { $0.playerId == MockedData.playerName })?.event as? MUXSDKOrientationChangeEvent else {
            XCTFail("MUXSDKOrientationChangeEvent not found")
            return
        }
        
        guard let viewData = lastDispatchedEvent.viewData else {
            XCTFail("View data for MUXSDKOrientationChangeEvent not found")
            return
        }
                                                             
        XCTAssertTrue(NSDictionary(dictionary: viewData.toQuery()).isEqual(to: expectedData))
    }
}
