//
//  MUXSDKConnection.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 25/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import Network
import UIKit

enum MUXSDKConnection {
    static let ConnectionTypeDetectedNotification = NSNotification.Name("com.mux.connection-type-detected")
    private static var isMonitoring: Bool = false
    
    static func detectConnectionType() {
        let queue = DispatchQueue.global(qos: .background)
        
        guard !Self.isMonitoring else {
            return
        }

        let monitor = NWPathMonitor()

        monitor.pathUpdateHandler = { path in
            var connectionType: String? = nil

            if path.usesInterfaceType(.wifi) {
                connectionType = "wifi"
            } else if path.usesInterfaceType(.cellular) {
                connectionType = "cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                connectionType = "wired"
            }

            NotificationCenter.default.post(name: ConnectionTypeDetectedNotification, object: connectionType)
        }

        monitor.start(queue: queue)
        Self.isMonitoring = true

    }
}
