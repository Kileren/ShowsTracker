//
//  ShowsTrackerApp.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import Resolver

@main
struct ShowsTrackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let notificationCenterDelegate = NotificationCenterDelegate()
    private let rootManager = RootManager()
    
    @ObservedObject private var themeManager: ThemeManager = .shared
    
    @Injected private var analyticsService: AnalyticsService
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    analyticsService.setUserID()
                    analyticsService.logAppLaunch()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      guard let fileName = Bundle.main.infoDictionary?["FIREBASE_CONFIG_FILE"] as? String,
            let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath) else {
          Logger.log(warning: "Firebase not configured")
          return true
      }
      
      FirebaseApp.configure(options: options)
      return true
  }
}
