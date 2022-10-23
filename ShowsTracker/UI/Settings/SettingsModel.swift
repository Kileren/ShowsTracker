//
//  SettingsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation

struct SettingsModel {
    var notificationsState: NotificationsState = .empty
    
    enum NotificationsState {
        case on
        case off
        case empty
    }
}
