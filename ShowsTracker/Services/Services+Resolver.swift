//
//  Services+Resolver.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import Foundation
import Resolver

extension Resolver {
    static func registerServices() {
        register { ImageLoader() }
    }
}
