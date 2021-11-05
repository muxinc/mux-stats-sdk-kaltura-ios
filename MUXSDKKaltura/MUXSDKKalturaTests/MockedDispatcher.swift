//
//  MockedDispatcher.swift
//  MUXSDKKalturaTests
//
//  Created by Stephanie Zuñiga on 27/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
@testable import MUXSDKKaltura
import MuxCore

class MockedDispatcher: MUXSDKKaltura.MUXSDKDispatcher {
    func dispatchGlobalDataEvent(_ event: MUXSDKDataEvent) {
        print("dispatch global data event: \(event)")
    }
    
    func dispatchEvent(_ event: MUXSDKEventTyping, forPlayer playerId: String) {
        print("dispatch event: \(event) for player: \(playerId)")
    }
    
    func destroyPlayer(_ playerId: String) {
        print("destroy player \(playerId)")
    }
}
