//
//  MUXSDKDispatcher.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 27/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

protocol MUXSDKDispatcher {
    func dispatchGlobalDataEvent(_ event: MUXSDKDataEvent)
    func dispatchEvent(_ event: MUXSDKEventTyping, forPlayer playerId: String)
    func destroyPlayer(_ playerId: String)
}
