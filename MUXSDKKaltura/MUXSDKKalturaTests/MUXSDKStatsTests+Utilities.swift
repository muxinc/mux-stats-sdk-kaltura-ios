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
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerVideoData = dispatchedEvent?.customerVideoData  else {
            XCTAssertNil(dispatchedEvent?.customerVideoData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerVideoData.toQuery()).isEqual(to: expectedCustomerVideoData))
    }
    
    func assertDispatchedCustomerPlayerDataEventsAtIndex(index: Int, expectedCustomerPlayerData: [String : Any]) {
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerPlayerData = dispatchedEvent?.customerPlayerData else {
            XCTAssertNil(dispatchedEvent?.customerPlayerData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerPlayerData.toQuery()).isEqual(to: expectedCustomerPlayerData))
    }
    
    func assertDispatchedCustomerViewDataEventsAtIndex(index: Int, expectedCustomerViewData: [String : Any]) {
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customerViewData = dispatchedEvent?.customerViewData else {
            XCTAssertNil(dispatchedEvent?.customerViewData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customerViewData.toQuery()).isEqual(to: expectedCustomerViewData))
    }
    
    func assertDispatchedCustomerViewerDataEventsAtIndex(index: Int, expectedCustomerViewerData: String) {
        let dispatchedGlobalEvent = MockedData.dispatcher.dispatchedGlobalDataEvents[index]
        guard let viewerData = dispatchedGlobalEvent.viewerData else {
            XCTAssertNil(dispatchedGlobalEvent.viewerData)
            return
        }
        
        XCTAssertEqual(viewerData.viewerApplicationName, expectedCustomerViewerData)
    }
    
    func assertDispatchedCustomDataEventsAtIndex(index: Int, expectedCustomData: [String : Any]) {
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        guard let customData = dispatchedEvent?.customData else {
            XCTAssertNil(dispatchedEvent?.customData)
            return
        }
        
        XCTAssertTrue(NSDictionary(dictionary: customData.toQuery()).isEqual(to: expectedCustomData))
    }
}
