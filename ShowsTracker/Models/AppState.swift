//
//  AppState.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var shows: [Show] = [Show(image: Image("TheWitcher")), Show(image: Image("TheMandalorian"))]
}
