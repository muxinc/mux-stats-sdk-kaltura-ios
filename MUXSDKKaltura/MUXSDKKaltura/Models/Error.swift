//
//  Error.swift
//  MUXSDKKaltura
//
//  Created by Stephanie Zuñiga on 4/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation

struct Error: Codable {
    let level: Level
    let domain: String?
    let code: String
    let message: String
    
    init(level: Level, domain: String?, code: Int, message: String? = nil) {
        self.level = level
        self.domain = domain
        self.code = "\(code)"
        self.message = message ?? "n/a"
    }
    
    enum Level: String, Codable {
        case player = "p"
        case log = "l"
    }
    
    private enum CodingKeys : String, CodingKey {
        case level = "l"
        case domain = "d"
        case code = "c"
        case message = "m"
    }
}
