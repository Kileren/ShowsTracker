//
//  RootManager.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import UIKit
import SwiftUI
import Resolver

final class RootManager {
    
    @Injected private var pingService: IPingService
    
    @AppSettings<AppLanguageKey> private var appLanguage
    @AppSettings<LastUpdatesCheckKey> private var lastUpdatesCheck
    
    init() {
        setupUI()
        addObservers()
        saveCurrentLanguage()
        setLastUpdatesCheckIfNeeded()
    }
    
    func setupUI() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.dynamic.text100)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.dynamic.text100)]
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
        
        Task {
            guard !isPreview else { return }
            
            let serverAvailable = await pingService.ping()
            if !serverAvailable {
                await showNetworkErrorView()
            }
        }
    }
    
    func saveCurrentLanguage() {
        if let preferredLanguage = NSLocale.preferredLanguages.first,
           let language = AppLanguage.allCases.first(where: { preferredLanguage.starts(with: $0.rawValue) }) {
            appLanguage = language.rawValue
        }
    }
    
    func setLastUpdatesCheckIfNeeded() {
        if lastUpdatesCheck == nil {
            lastUpdatesCheck = Date()
        }
    }
}

private extension RootManager {
    @MainActor
    func showNetworkErrorView() {
        guard let topViewController = UIApplication.shared.topViewController else {
            assertionFailure("Top view controller doesn't exist")
            return
        }
        if topViewController is UIHostingController<NetworkErrorView> {
            // NetworkErrorView already shown
            return
        }
        let hostingViewController = UIHostingController(rootView: NetworkErrorView())
        hostingViewController.modalPresentationStyle = .fullScreen
        hostingViewController.modalTransitionStyle = .crossDissolve
        topViewController.present(hostingViewController, animated: true)
    }
}
