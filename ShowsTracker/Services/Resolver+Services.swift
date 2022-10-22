//
//  Resolver+Services.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import Resolver

extension Resolver {
    static func registerOtherServices() {
        register { NotificationsService() }.scope(.application)
    }
}
