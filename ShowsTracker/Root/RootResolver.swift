//
//  RootResolver.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { AppState() }.scope(.application)
        registerMainDependencies()
    }
}

#if DEBUG
extension Resolver {
    static func registerPreview() {
        register { AppState() }.scope(.application)
    }
}
#endif
