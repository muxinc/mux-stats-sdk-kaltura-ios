//
//  MUXSDKMainDispatcher.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 27/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MUXSDKMainDispatcher: MUXSDKDispatcher {
    func dispatchGlobalDataEvent(_ event: MUXSDKDataEvent) {
        MUXSDKCore.dispatchGlobalDataEvent(event)
    }
    
    func dispatchEvent(_ event: MUXSDKEventTyping, forPlayer playerId: String) {
        MUXSDKCore.dispatchEvent(event, forPlayer: playerId)
    }
    
    func destroyPlayer(_ playerId: String) {
        MUXSDKCore.destroyPlayer(playerId)
    }
}
