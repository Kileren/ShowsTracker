//
//  AppState.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Combine
import SwiftUI

class AppState: ObservableObject {
    @Published var shows: [DetailedShow] = []
    @Published var popularShows: [PlainShow] = []
    @Published var selectedTabBarView: STTabBarButton = .shows
    @Published var showDetails: ShowDetails = ShowDetails()
    
    let info: Store<Info>
    let routing: Store<Routing>
    
    init() {
        info = Store<Info>(Info())
        routing = Store<Routing>(Routing())
    }
}

extension AppState {
    struct Info: Equatable {
        var showDetails: [Int: ShowDetailsView.Model] = [:]
    }
    
    struct Routing: Equatable {
        var shows: ShowsView.Routing = .init()
        var showDetails: ShowDetailsView.Routing = .init()
    }
}

enum STTabBarButton {
    case shows
    case movies
    case profile
}

extension Dictionary where Key == Int, Value == ShowDetailsView.Model {
    subscript(key: Key) -> Value {
        self[key] ?? Value()
    }
}
