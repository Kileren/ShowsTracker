//
//  RootManager.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import UIKit
import SwiftUI

final class RootManager {
    
    @AppSettings<AppLanguageKey> private var appLanguage
    
    init() {
        setupUI()
        addObservers()
        saveCurrentLanguage()
    }
    
    func setupUI() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.text100)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.text100)]
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func willEnterForeground() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func saveCurrentLanguage() {
        if let preferredLanguage = NSLocale.preferredLanguages.first,
           let language = AppLanguage.allCases.first(where: { preferredLanguage.starts(with: $0.rawValue) }) {
            appLanguage = language.rawValue
        }
    }
}
