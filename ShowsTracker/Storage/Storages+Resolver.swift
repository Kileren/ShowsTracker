//
//  Storages+Resolver.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 18.06.2022.
//

import Resolver

extension Resolver {
    static func registerStorages() {
        register { CoreDataStorage() }
            .implements(ICoreDataStorage.self)
            .scope(.application)
    }
}
