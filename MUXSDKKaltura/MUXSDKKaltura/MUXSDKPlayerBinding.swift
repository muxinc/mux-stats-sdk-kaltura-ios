//
//  MUXSDKPlayerBinding.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 23/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import PlayKit

@objc
public class MUXSDKPlayerBinding: NSObject {
    private var name: String?
    private var software: String?
    private var player: Player?
    private var automaticErrorTracking: Bool
    
    init(name: String, software: String, player: Player, automaticErrorTracking: Bool) {
        self.name = name
        self.software = software
        self.player = player
        self.automaticErrorTracking = automaticErrorTracking
    }
    
    func attachPlayer(_ player: Player) {
        if self.player != nil {
            self.detachPlayer()
        }
        
        self.player = player
    }
    
    func detachPlayer() {
        self.player = nil
    }
}
