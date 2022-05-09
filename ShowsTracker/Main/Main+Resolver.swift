//
//  Main+Resolver.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Resolver

extension Resolver {
    static func registerMainDependencies() {
        register { ShowsViewInteractor(appState: resolve()) }
        register { ShowDetailsViewInteractor() }
        register { ShowsListViewInteractor() }
    }
}
