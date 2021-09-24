//
//  MUXSDKPlayerBindingManager.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation

class MUXSDKPlayerBindingManager {
    var bindings: [String: MUXSDKPlayerBinding] = [:]
    
    // Customer Data Store
    let customerDataStore = MUXSDKCustomerDataStore()
    
    func destroyPlayer(name: String) {
        // Remove from bindings with key name and call viewEnd and detachPlayer
    }
    
    func createNewViewForPlayer(name: String) {
        
    }
}
