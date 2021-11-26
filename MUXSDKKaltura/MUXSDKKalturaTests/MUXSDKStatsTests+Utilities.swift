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
    private enum EventType{
        case customerVideoData
        case customerPlayerData
        case customerData
        case customData
    }
    
    func assertDispatchedEventTypesForPlayer(id: String, expectedEventTypes: [String]) {
        let dispatchedEventsType = MockedDispatcher.shared.dispatchedEvents
            .filter { $0.playerId == id }
            .map { $0.event.getType() }
        
        XCTAssertEqual(expectedEventTypes, dispatchedEventsType)
    }
    
    func assertDispatchedCustomerDataEventsAtIndex(
        index: Int,
        expectedCustomerVideoData: [String : Any]? = nil,
        expectedCustomerPlayerData: [String : Any]? = nil,
        expectedCustomerViewData: [String : Any]? = nil,
        expectedCustomData: [String : Any]? = nil
    )  {
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        if let expectedCustomerVideoData = expectedCustomerVideoData {
            assertCustomerData(type: .customerVideoData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerVideoData)
        } else {
            XCTAssertNil(expectedCustomerVideoData)
        }
        if let expectedCustomerPlayerData = expectedCustomerPlayerData {
            assertCustomerData(type: .customerPlayerData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerPlayerData)
        } else {
            XCTAssertNil(expectedCustomerPlayerData)
        }
        if let expectedCustomerViewData = expectedCustomerViewData {
            assertCustomerData(type: .customerData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerViewData)
        } else {
            XCTAssertNil(expectedCustomerViewData)
        }
        if let expectedCustomData = expectedCustomData {
            assertCustomerData(type: .customData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomData)
        } else {
            XCTAssertNil(expectedCustomData)
        }
    }
    
    private func assertCustomerData(type: EventType, dispatchedEvent: MUXSDKDataEvent?, expectedData: [String : Any]) {
        switch type {
        case .customerVideoData:
            guard let customerVideoData = dispatchedEvent?.customerVideoData else {
                XCTFail("Customer video data for dispatched event not found")
                return
            }
            XCTAssertTrue(NSDictionary(dictionary: customerVideoData.toQuery()).isEqual(to: expectedData))
        case .customerPlayerData:
            guard let customerPlayerData = dispatchedEvent?.customerPlayerData else {
                XCTFail("Customer player data for dispatched event not found")
                return
            }
            XCTAssertTrue(NSDictionary(dictionary: customerPlayerData.toQuery()).isEqual(to: expectedData))
        case .customerData:
            guard let customerData = dispatchedEvent?.customerViewData else {
                XCTFail("Customer data for dispatched event not found")
                return
            }
            XCTAssertTrue(NSDictionary(dictionary: customerData.toQuery()).isEqual(to: expectedData))
        case .customData:
            guard let customData = dispatchedEvent?.customData else {
                XCTFail("Custom data for dispatched event not found")
                return
            }
            XCTAssertTrue(NSDictionary(dictionary: customData.toQuery()).isEqual(to: expectedData))
        }
    }
    
    func assertDispatchedCustomerViewerDataEventsAtIndex(index: Int, expectedCustomerViewerData: String) {
        let dispatchedGlobalEvent = MockedData.dispatcher.dispatchedGlobalDataEvents[index]
        guard let viewerData = dispatchedGlobalEvent.viewerData else {
            XCTAssertNil(dispatchedGlobalEvent.viewerData)
            return
        }
        XCTAssertEqual(viewerData.viewerApplicationName, expectedCustomerViewerData)
    }
}
