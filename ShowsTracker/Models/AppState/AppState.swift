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
    
    private var anyCancellable: AnyCancellable? = nil
    
    init() {
        anyCancellable = showDetails.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}

enum STTabBarButton {
    case shows
    case movies
    case profile
}
