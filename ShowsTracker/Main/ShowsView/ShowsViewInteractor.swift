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
    @Injected private var coreDataStorage: ICoreDataStorage
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        Task {
            let savedShows = coreDataStorage.get(object: PlainShow.self)
            var userShows: [ShowsView.Model.UserShow] = []
            for show in savedShows {
                // TODO: make concurrent loading
                let image = try await imageService.loadImage(path: show.posterPath ?? "", width: 500).wrapInImage()
                userShows.append(.init(id: show.id, image: image))
            }
            
            var model = ShowsView.Model(
                isUserShowsLoaded: true,
                isPopularShowsLoaded: false,
                userShows: userShows,
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
