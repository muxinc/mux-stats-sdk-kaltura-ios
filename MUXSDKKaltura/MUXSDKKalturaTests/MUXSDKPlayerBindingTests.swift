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
}

extension MUXSDKPlayerBindingTests {
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
