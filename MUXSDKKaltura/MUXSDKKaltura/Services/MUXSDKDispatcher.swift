//
//  MUXSDKDispatcher.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 27/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MUXSDKDispatcher: MUXSDKDispatcherType {
    func dispatchGlobalDataEvent(_ event: MUXSDKDataEvent) {
        MUXSDKCore.dispatchGlobalDataEvent(event)
    }
}
