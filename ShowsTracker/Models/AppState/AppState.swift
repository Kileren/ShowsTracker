//
//  AppState.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Combine
import SwiftUI

class AppState: ObservableObject {
    
    let info: Store<Info>
    let routing: Store<Routing>
    let service: Store<Service>
    
    init() {
        info = Store(Info())
        routing = Store(Routing())
        service = Store(Service())
    }
}

extension AppState {
    struct Info: Equatable {
        var tabBar: TabBarView.Model = .init()
        var shows: ShowsView.Model = .init()
        var showDetails: [Int: ShowDetailsView.Model] = [:]
        var showsList: ShowsListView.Model = .init()
    }
    
    struct Routing: Equatable {
        var shows: ShowsView.Routing = .init()
        var showDetails: ShowDetailsView.Routing = .init()
    }
    
    struct Service: Equatable {
        var shownDetailsIDs: Set<Int> = []
    }
}

extension Dictionary where Key == Int, Value == ShowDetailsView.Model {
    subscript(key: Key) -> Value {
        self[key] ?? Value()
    }
}
