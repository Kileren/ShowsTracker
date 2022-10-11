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
            TabBarView()
                .onAppear {
                    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.text100)]
                    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.text100)]
                }
//            Example()
        }
    }
}
