//
//  SettingsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation

struct SettingsModel {
    var notificationsState: NotificationsState = .empty
    var selectedLanguage: String = ""
    
    enum NotificationsState {
        case on
        case off
        case empty
    }
}
