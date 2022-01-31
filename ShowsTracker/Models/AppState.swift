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
    
//    @Published var shows: [DetailedShow] = [
//        DetailedShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
//        DetailedShow(imageData: UIImage(named: "TheMandalorian")?.pngData())
//    ]
//
//    @Published var popularShows: [PlainShow] = [
//        PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
//        PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData()),
//        PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
//        PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData()),
//        PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
//        PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData())
//    ]
}

enum STTabBarButton {
    case shows
    case movies
    case profile
}
