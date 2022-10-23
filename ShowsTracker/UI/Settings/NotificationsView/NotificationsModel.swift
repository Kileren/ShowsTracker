//
//  NotificationsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation

struct NotificationsModel {
    
    var selectedTime = Date(timeIntervalSinceReferenceDate: 0)
    var state: State = .loading
    
    enum State {
        case allowed
        case denied
        case notDetermined
        case loading
    }
}

