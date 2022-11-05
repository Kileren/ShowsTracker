//
//  AppTheme.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 05.11.2022.
//

import Foundation

enum AppTheme: String, CaseIterable {
    case light
    case dark
    case unspecified
    
    init(rawValue: String) {
        switch rawValue {
        case AppTheme.light.rawValue: self = .light
        case AppTheme.dark.rawValue: self = .dark
        default: self = .unspecified
        }
    }
}
