//
//  MUXSDKStatsTests+Utilities.swift
//  MUXSDKKalturaTests
//
//  Created by Audra Rodriguez on 18/11/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import XCTest
@testable import MUXSDKKaltura
import MuxCore

extension MUXSDKStatsTests {
    func assertDispatchedEventTypesForPlayer(id: String, expectedEventTypes: [String]) {
        let dispatchedEventsType = MockedDispatcher.shared.dispatchedEvents
            .filter { $0.playerId == id }
            .map { $0.event.getType() }
        
        XCTAssertEqual(expectedEventTypes, dispatchedEventsType)
    }
    
    func assertDispatchedCustomerVideoDataEventsAtIndex(index: Int, expectedCustomerVideoData: [String : Any]) {
        let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerVideoData = lastDispatchedEvent?.customerVideoData  else {
            XCTAssertNil(lastDispatchedEvent?.customerVideoData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerVideoData.toQuery()).isEqual(to: expectedCustomerVideoData))
    }
    
    func assertDispatchedCustomerPlayerDataEventsAtIndex(index: Int, expectedCustomerPlayerData: [String : Any]) {
        let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerPlayerData = lastDispatchedEvent?.customerPlayerData else {
            XCTAssertNil(lastDispatchedEvent?.customerPlayerData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerPlayerData.toQuery()).isEqual(to: expectedCustomerPlayerData))
    }
    
    func assertDispatchedCustomerViewDataEventsAtIndex(index: Int, expectedCustomerViewData: [String : Any]) {
        let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerViewData = lastDispatchedEvent?.customerViewData else {
            XCTAssertNil(lastDispatchedEvent?.customerViewData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerViewData.toQuery()).isEqual(to: expectedCustomerViewData))
    }
    
    func assertDispatchedCustomerViewerDataEventsAtIndex(index: Int, expectedCustomerViewerData: [String : Any]) {
        let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let viewerData = lastDispatchedEvent?.viewerData else {
            XCTAssertNil(lastDispatchedEvent?.viewerData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: viewerData.toQuery()).isEqual(to: expectedCustomerViewerData))
    }
    
    func assertDispatchedCustomDataEventsAtIndex(index: Int, expectedCustomData: [String : Any]) {
        let lastDispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customData = lastDispatchedEvent?.customData else {
            XCTAssertNil(lastDispatchedEvent?.customData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customData.toQuery()).isEqual(to: expectedCustomData))
    }
}
