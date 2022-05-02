//
//  STDateFormatter.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import Foundation

struct STDateFormatter {
    
    enum Format: String {
        case full = "dd MMMM yyyy"
    }
    
    static func format(_ value: String, format: Format) -> String {
        let initialFormat = "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = initialFormat
        
        guard let date = formatter.date(from: value) else { return value }
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
}
