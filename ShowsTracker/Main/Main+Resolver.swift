//
//  Main+Resolver.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Resolver

extension Resolver {
    static func registerMainDependencies() {
        register { ShowsViewModel() }
        register { ShowsListViewModel() }
        register { ShowDetailsViewModel() }
        register { ArchiveShowsViewModel() }
    }
}
