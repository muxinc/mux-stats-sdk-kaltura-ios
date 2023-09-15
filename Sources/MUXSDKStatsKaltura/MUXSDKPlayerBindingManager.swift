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
    let dispatcher: MUXSDKDispatcher
    
    // Customer Data Store
    let customerDataStore = MUXSDKCustomerDataStore()

    init(dispatcher: MUXSDKDispatcher) {
        self.dispatcher = dispatcher
    }
    
    func destroyPlayer(name: String) {
        guard let binding = bindings[name] else {
            SDKLogger.log("MUXSDK-WARNING - Player binding not found for player name: \(name).")
            return
        }
        
        binding.dispatchViewEnd()
        binding.detachPlayer()
        
        // Remove from bindings dictionary
        bindings.removeValue(forKey: name)
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

extension MUXSDKPlayerBindingManager: PlayDispatchDelegate {
    func playbackStartedForPlayer(name: String) {
        // Confirm binding has been initialized
        guard let binding = self.bindings[name], binding.initialized else {
            SDKLogger.log("MUXSDK-WARNING - Detected SDK initialized after playback has started.")
            self.createNewViewForPlayer(name: name)
            return
        }
    }
    
    func videoChangedForPlayer(name: String) {
        guard let binding = self.bindings[name] else {
            return
        }
        
        binding.dispatchViewInit()
        
        guard let customerData = self.customerDataStore.dataForPlayerName(name) else {
            return
        }
        self.dispatchDataEventForPlayer(name: name, customerData: customerData, videoChange: true)
    }
}

