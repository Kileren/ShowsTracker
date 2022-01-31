//
//  ShowsTrackerApp.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI

@main
struct ShowsTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                TabBarView(geometry: geometry)
            }
//            ShowsView()
//            Example()
        }
    }
}