//
//  STNumberFormatter.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import Foundation

struct STNumberFormatter {
    enum Format {
        case vote
    }
    
    static func format(_ value: Double, format: Format) -> String {
        let formatter = NumberFormatter()
        switch format {
        case .vote:
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1
        }
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
