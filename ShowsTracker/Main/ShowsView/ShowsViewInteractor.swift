//
//  ShowsViewInteractor.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Foundation
import UIKit
import SwiftUI
import Resolver

final class ShowsViewInteractor: ObservableObject {
    
    private var appState: AppState
    @Injected var imageService: IImageService
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        Task {
            let witcherImage = try await imageService.loadImage(path: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg", width: 500).wrapInImage()
            let mandalorianImage = try await imageService.loadImage(path: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg", width: 500).wrapInImage()
            
            let model = ShowsView.Model(
                isUserShowsLoaded: false,
                isPopularShowsLoaded: false,
                userShows: [
                    .init(id: 71912, posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg", image: witcherImage),
                    .init(id: 82856, posterPath: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg", image: mandalorianImage)
                ],
                popularShows: [
                    .init(id: 71912, posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg"),
                    .init(id: 82856, posterPath: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg")
                ])
            
            appState.info[\.shows] = model
            
            // TODO: Remove it later
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.appState.info[\.shows.isUserShowsLoaded] = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.appState.info[\.shows.isPopularShowsLoaded] = true
                }
            }
        }
    }
}
