//
//  UIApplication+Extensions.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.11.2022.
//

import UIKit

extension UIApplication {
    
    var keyWindowScene: UIWindowScene? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user (only for apps with multi scenes)
            // .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })
    }
    
    var keyWindow: UIWindow? {
        // Get window scene
        return keyWindowScene?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    var topViewController: UIViewController? {
        guard var viewController = keyWindow?.rootViewController else { return nil }
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }
        return viewController
    }
}
