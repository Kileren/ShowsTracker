//
//  AppState.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var shows: [DetailedShow] = []
    @Published var popularShows: [PlainShow] = []
    
    @Published var selectedTabBarView: STTabBarButton = .shows
    
    @Published var detailedShowId: Int = 0
    @Published var detailedShow: DetailedShow = .zero
    @Published var detailedShowLoaded: Bool = false
}

enum STTabBarButton {
    case shows
    case movies
    case profile
}
