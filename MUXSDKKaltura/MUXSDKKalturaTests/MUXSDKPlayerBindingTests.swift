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
        let data = Self.binding.buildBandwidthMetricData(
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
        Self.binding.attachPlayer(Self.player)
        
        Self.binding.dispatchOrientationChange(orientation: .portrait)
        
        let expectedData: [String : Any] = [
            "xdvor": [
                "x": 0,
                "y": 0,
                "z": 90
            ]
        ]
        
        guard let lastDispatchedEvent = Self.dispatcher.dispatchedEvents.last(where: { $0.playerId == Self.playerName })?.event as? MUXSDKOrientationChangeEvent else {
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
        Self.binding.attachPlayer(Self.player)
        
        Self.binding.dispatchOrientationChange(orientation: .landscape)
        
        let expectedData: [String : Any] = [
            "xdvor": [
                "x": 0,
                "y": 0,
                "z": 0
            ]
        ]
        
        guard let lastDispatchedEvent = Self.dispatcher.dispatchedEvents.last(where: { $0.playerId == Self.playerName })?.event as? MUXSDKOrientationChangeEvent else {
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

extension MUXSDKPlayerBindingTests {
    static let player = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
    
    static let playerName = "Test Player"
    
    static let dispatcher = MockedDispatcher()
    
    static let bindingManager = MUXSDKPlayerBindingManager(dispatcher: dispatcher)
    
    static let binding = MUXSDKPlayerBinding(
        name: playerName,
        software: "KalturaPlayer",
        automaticErrorTracking: true,
        playDispatchDelegate: bindingManager,
        dispatcher: dispatcher
    )
}
