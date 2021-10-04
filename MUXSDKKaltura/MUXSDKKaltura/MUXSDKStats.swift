//
//  MUXSDKStats.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import PlayKit
import MuxCore

@objc
public class MUXSDKStats: NSObject {
    private static let MuxPlayerSoftwareKalturaPlayer = "KalturaPlayer"
    private static let bindingsManager = MUXSDKPlayerBindingManager()
    
    /**
     Starts to monitor a given Kaltura PlayKit Player.
     
     Use this method to start a Mux player monitor on the given Kaltura PlayKit Player. The player must have a name which is globally unique. The config provided should match the specifications in the Mux docs at https://docs.mux.com
     
     - Parameters:
        - player: A PlayKit Player to monitor
        - playerName: A name for this instance of the player
        - customerData: A MUXSDKCustomerData object with player, video, and view metadata
        - automaticErrorTracking: boolean to indicate if the SDK should automatically track player errors
        - beaconDomain: Domain to send tracking data to, if you want to use a custom beacon domain. Optional.
     - Returns: An instance of MUXSDKPlayerBinding or null
     */
    @discardableResult
    @objc
    public static func monitorPlayer(
        player: Player,
        playerName: String,
        customerData: MUXSDKCustomerData,
        automaticErrorTracking: Bool = true,
        beaconDomain: String? = nil
    ) -> MUXSDKPlayerBinding {
        self.initSDK()
        
        // Destroy any previously existing player with this name
        if bindingsManager.bindings[playerName] != nil {
            bindingsManager.destroyPlayer(name: playerName)
        }
        
        if let beacon = beaconDomain, !beacon.isEmpty {
            MUXSDKCore.setBeaconDomain(beacon, forPlayer: playerName)
        }
        
        let newBinding = MUXSDKPlayerBinding(
            name: playerName,
            software: MuxPlayerSoftwareKalturaPlayer,
            player: player,
            automaticErrorTracking: automaticErrorTracking
        )
        newBinding.attachPlayer(player)
        
        bindingsManager.bindings[playerName] = newBinding
        bindingsManager.customerDataStore.setData(customerData, forPlayerName: playerName)
        bindingsManager.createNewViewForPlayer(name: playerName)
        
        return newBinding
    }
    
    static func initSDK() {
        // Provide EnvironmentData and ViewerData to Core
    }
}

