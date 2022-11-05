//
//  ShowsTrackerApp.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI

@main
struct ShowsTrackerApp: App {
    
    private let notificationCenterDelegate = NotificationCenterDelegate()
    private let rootManager = RootManager()
    
    @ObservedObject private var themeManager: ThemeManager = .shared
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
