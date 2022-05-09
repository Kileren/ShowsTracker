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
    
    private let appState: AppState
    @Injected private var imageService: IImageService
    @Injected private var tvService: ITVService
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        Task {
            let witcherImage = try await imageService.loadImage(path: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg", width: 500).wrapInImage()
            let mandalorianImage = try await imageService.loadImage(path: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg", width: 500).wrapInImage()
            
            var model = ShowsView.Model(
                isUserShowsLoaded: true,
                isPopularShowsLoaded: false,
                userShows: [
                    .init(id: 71912, posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg", image: witcherImage),
                    .init(id: 82856, posterPath: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg", image: mandalorianImage)
                ],
                popularShows: [])
            
            await setModel(model)
            
            let popularShows = try await tvService.getPopular()
            model.popularShows = popularShows.map { .init(id: $0.id, posterPath: $0.posterPath ?? "") }
            model.isPopularShowsLoaded = true
            
            await setModel(model)
        }
    }
    
    @MainActor
    func setModel(_ model: ShowsView.Model) {
        appState.info[\.shows] = model
    }
}
