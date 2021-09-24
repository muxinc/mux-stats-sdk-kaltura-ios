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
    
    func setData(_ data: MUXSDKCustomerData, forPlayerName name: String) {
        self.store[name] = data
    }
    
    func dataForPlayerName(_ name: String) -> MUXSDKCustomerData? {
        return self.store[name]
    }
}
