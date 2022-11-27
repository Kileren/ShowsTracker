//
//  UIScreen+Extensions.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 27.11.2022.
//

import UIKit

extension UIScreen {
    static var hasNotch: Bool {
        guard let keyWindow = UIApplication.shared.keyWindowScene?.keyWindow else { return true }
        return keyWindow.safeAreaInsets.top > 20
    }
}
