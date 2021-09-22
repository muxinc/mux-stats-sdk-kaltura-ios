//
//  TimeInterval+Format.swift
//  DemoApp
//
//  Created by Stephanie Zuñiga on 22/9/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation

extension TimeInterval {
    var formattedTimeDisplay: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if let timeDisplay = formatter.string(from: self) {
            return timeDisplay.count > 4 ? timeDisplay : "0" + timeDisplay
        } else {
            return "00:00"
        }
    }
}
