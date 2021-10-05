//
//  MUXSDKPlayerBindingManager.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MUXSDKPlayerBindingManager {
    var bindings: [String: MUXSDKPlayerBinding] = [:]
    let dispatcher: MUXSDKDispatcherType
    
    // Customer Data Store
    let customerDataStore = MUXSDKCustomerDataStore()

    init(dispatcher: MUXSDKDispatcherType) {
        self.dispatcher = dispatcher
    }
    
    func destroyPlayer(name: String) {
        // Remove from bindings with key name and call viewEnd and detachPlayer
    }
    
    func createNewViewForPlayer(name: String) {
        guard let binding = bindings[name], !binding.initialized else {
            return // binding doesn't exist
        }
        
        binding.dispatchViewInit()
        
        if let customerData = self.customerDataStore.dataForPlayerName(name) {
            self.dispatchDataEventForPlayer(
                name: name,
                customerData: customerData,
                videoChange: false
            )
        }
        
        binding.dispatchPlayerReady()
        binding.initialize()
    }
    
    func dispatchDataEventForPlayer(
        name: String,
        customerData: MUXSDKCustomerData,
        videoChange: Bool
    ) {
        guard
            customerData.customerPlayerData != nil ||
            customerData.customerVideoData  != nil ||
            customerData.customerViewData != nil ||
            customerData.customData != nil
        else {
            return
        }
        
        let dataEvent = MUXSDKDataEvent()
        dataEvent.customerPlayerData = customerData.customerPlayerData
        dataEvent.customerVideoData = customerData.customerVideoData
        dataEvent.customerViewData = customerData.customerViewData
        dataEvent.customData = customerData.customData
        dataEvent.videoChange = videoChange
        
        self.dispatcher.dispatchEvent(dataEvent, forPlayer: name)
    }
}
