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
    private enum MUXSDKDataEventType{
        case customerVideoData
        case customerPlayerData
        case customerData
        case customData
    }
    
    func assertDispatchedEventTypesMatch(expectedEventTypes: [String], for playerId: String) {
        let dispatchedEventsType = MockedDispatcher.shared.dispatchedEvents
            .filter { $0.playerId == playerId }
            .map { $0.event.getType() }
        
        XCTAssertEqual(expectedEventTypes, dispatchedEventsType)
    }
    
    func assertDispatchedCustomerDataEventsMatch(
        expectedCustomerVideoData: [String : Any]? = nil,
        expectedCustomerPlayerData: [String : Any]? = nil,
        expectedCustomerViewData: [String : Any]? = nil,
        expectedCustomData: [String : Any]? = nil,
        at index: Int
    )  {
        let dispatchedEvent = MockedData.dispatcher.dispatchedEvents[index].event as? MUXSDKDataEvent
        assertCustomerData(type: .customerVideoData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerVideoData)
        assertCustomerData(type: .customerPlayerData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerPlayerData)
        assertCustomerData(type: .customerData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomerViewData)
        assertCustomerData(type: .customData, dispatchedEvent: dispatchedEvent, expectedData: expectedCustomData)
    }
    
    private func assertCustomerData(type: MUXSDKDataEventType, dispatchedEvent: MUXSDKDataEvent?, expectedData: [String : Any]?) {
        switch type {
        case .customerVideoData:
            if let expectedCustomerVideoData = expectedData {
                guard let customerVideoData = dispatchedEvent?.customerVideoData else {
                    XCTFail("Customer video data for dispatched event not found")
                    return
                }
                XCTAssertTrue(NSDictionary(dictionary: customerVideoData.toQuery()).isEqual(to: expectedCustomerVideoData))
            } else {
                XCTAssertNil(dispatchedEvent?.customerVideoData)
            }
        case .customerPlayerData:
            if let expectedCustomerPlayerData = expectedData {
                guard let customerPlayerData = dispatchedEvent?.customerPlayerData else {
                    XCTFail("Customer player data for dispatched event not found")
                    return
                }
                XCTAssertTrue(NSDictionary(dictionary: customerPlayerData.toQuery()).isEqual(to: expectedCustomerPlayerData))
            } else {
                XCTAssertNil(dispatchedEvent?.customerPlayerData)
            }
        case .customerData:
            if let expectedCustomerViewData = expectedData {
                guard let customerData = dispatchedEvent?.customerViewData else {
                    XCTFail("Customer data for dispatched event not found")
                    return
                }
                XCTAssertTrue(NSDictionary(dictionary: customerData.toQuery()).isEqual(to: expectedCustomerViewData))
            } else {
                XCTAssertNil(dispatchedEvent?.customerViewData)
            }
        case .customData:
            if let expectedCustomData = expectedData {
                guard let customData = dispatchedEvent?.customData else {
                    XCTFail("Custom data for dispatched event not found")
                    return
                }
                XCTAssertTrue(NSDictionary(dictionary: customData.toQuery()).isEqual(to: expectedCustomData))
            } else {
                XCTAssertNil(dispatchedEvent?.customData)
            }
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
