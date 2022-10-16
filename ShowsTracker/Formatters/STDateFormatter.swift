//
//  STDateFormatter.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import Foundation

struct STDateFormatter {
    
    enum Format: String {
        /// dd MMMM yyyy
        case full = "dd MMMM yyyy"
        
        /// yyyy-MM-dd
        case airDate = "yyyy-MM-dd"
        
        /// MMM
        case shortMonth = "MMM"
        
        /// dd
        case day = "dd"
    }
    
    static func format(_ value: String, format: Format) -> String {
        let initialFormat = "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = initialFormat
        
        guard let date = formatter.date(from: value) else { return value }
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
    
    static func format(_ date: Date, format: Format) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
    
    static func component(_ component: Calendar.Component, from value: String, format: Format) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        guard let date = formatter.date(from: value) else { return nil }
        return Calendar.current.component(component, from: date)
    }
}
