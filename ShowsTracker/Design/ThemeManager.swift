//
//  ThemeManager.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.11.2022.
//

import Foundation
import SwiftUI

final class ThemeManager: ObservableObject {
    
    static var shared = ThemeManager()
    
    @AppSettings<AppThemeKey> private var appTheme
    
    @Published private(set) var colorScheme: ColorScheme? = nil
    
    func set(theme: AppTheme) {
        switch theme {
        case .light:
            if colorScheme != .light {
                colorScheme = .light
            }
        case .dark:
            if colorScheme != .dark {
                colorScheme = .dark
            }
        case .unspecified:
            if colorScheme != nil {
                colorScheme = nil
            }
        }
        
        appTheme = theme.rawValue
    }
    
    private init() {
        set(theme: AppTheme(rawValue: appTheme))
    }
}
