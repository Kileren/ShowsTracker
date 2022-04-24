//
//  RootResolver.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Resolver
import Foundation

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            registerPreview()
        } else {
            registerServices()
        }
        #else
        registerServices()
        #endif
    }
    
    private static func registerServices() {
        register { AppState() }.scope(.application)
        registerMainDependencies()
        registerNetworkServices()
    }
}

#if DEBUG
extension Resolver {
    static func registerPreview() {
        register { AppState() }.scope(.application)
        registerNetworkServicesPreview()
    }
}
#endif
