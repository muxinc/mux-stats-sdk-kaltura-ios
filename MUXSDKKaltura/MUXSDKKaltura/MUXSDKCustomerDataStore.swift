//
//  MUXSDKCustomerDataStore.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MUXSDKCustomerDataStore {
    private var store: [String: MUXSDKCustomerData] = [:]
    
    // Overwrites any pre-existing data for the player
    func setData(_ data: MUXSDKCustomerData, forPlayerName name: String) {
        self.store[name] = data
    }
    
    func updateData(
        customerPlayerData: MUXSDKCustomerPlayerData? = nil,
        customerVideoData: MUXSDKCustomerVideoData? = nil,
        customerViewData: MUXSDKCustomerViewData? = nil,
        customerViewerData: MUXSDKCustomerViewerData? = nil,
        customData: MUXSDKCustomData? = nil,
        forPlayerName name: String
    ) {
        // Get current data for player name
        let data = self.store[name]
        
        // Update data
        if let playerData = customerPlayerData {
            data?.customerPlayerData = playerData
        }
        
        if let videoData = customerVideoData {
            data?.customerVideoData = videoData
        }
        
        if let viewData = customerViewData {
            data?.customerViewData = viewData
        }
        
        if let viewerData = customerViewerData {
            data?.customerViewerData = viewerData
        }
        
        if let customData = customData {
            data?.customData = customData
        }
        
        // Store updated data
        self.store[name] = data
    }
    
    func dataForPlayerName(_ name: String) -> MUXSDKCustomerData? {
        return self.store[name]
    }
}
