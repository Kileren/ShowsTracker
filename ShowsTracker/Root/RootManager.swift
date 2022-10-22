//
//  RootManager.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import UIKit
import SwiftUI

final class RootManager {
    
    init() {
        setupUI()
        addObservers()
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
}
