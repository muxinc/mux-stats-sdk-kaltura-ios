//
//  MockedDispatcher.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 27/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MockedDispatcher: MUXSDKDispatcher {
    static let shared = MockedDispatcher()
    
    typealias PlayerEvent = (playerId: String, event: MUXSDKEventTyping)
    var dispatchedEvents = [PlayerEvent]()
    var dispatchedGlobalDataEvents = [MUXSDKDataEvent]()
    
    func dispatchGlobalDataEvent(_ event: MUXSDKDataEvent) {
        print("dispatch global data event: \(event)")
        self.dispatchedGlobalDataEvents.append(event)
    }
    
    func dispatchEvent(_ event: MUXSDKEventTyping, forPlayer playerId: String) {
        print("dispatch event: \(event) for player: \(playerId)")
        self.dispatchedEvents.append(PlayerEvent(playerId: playerId, event: event))
    }
    
    func destroyPlayer(_ playerId: String) {
        print("destroy player \(playerId)")
    }
}
