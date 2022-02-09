//
//  MUXSDKConnection.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 25/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import Network
import SystemConfiguration
import UIKit

enum MUXSDKConnection {
    static let ConnectionTypeDetectedNotification = NSNotification.Name("com.mux.connection-type-detected")
    private static var isMonitoring: Bool = false
    
    static func detectConnectionType() {
        let queue = DispatchQueue.global(qos: .background)
        
        if #available(iOS 12.0, tvOS 12.0, *) {
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
        } else {
            // Fallback for iOS < 12.0
            queue.async {
                Self.getConnectionTypeWithReachability()
            }
        }
    }
    
    static func getConnectionTypeWithReachability() {
        // SCNetworkReachability does not let us differentiate between wifi/ethernet
        // Because of the innaccuracy of the data for tvOS we don't send this data at all
        guard UIDevice.current.userInterfaceIdiom != .tv else {
            return
        }
        
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "8.8.8.8") else {
            return
        }
        
        var flags = SCNetworkReachabilityFlags()
        let getFlagsSuccess = SCNetworkReachabilityGetFlags(reachability, &flags)
        
        guard getFlagsSuccess else {
            return
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        var connectionType: String? = nil
        
        if isReachable && !needsConnection {
            if flags.contains(.isWWAN) {
                connectionType = "cellular"
            } else {
                connectionType = "wifi"
            }
        }
        
        NotificationCenter.default.post(name: ConnectionTypeDetectedNotification, object: connectionType)
    }
}
