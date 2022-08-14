//
//  ShowsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.07.2022.
//

import SwiftUI
import Resolver

final class ShowsViewModel: ObservableObject {
    
    @Published var model: ShowsView.Model = .init()
    
    @Injected private var imageService: IImageService
    @Injected private var tvService: ITVService
    @Injected private var coreDataStorage: ICoreDataStorage
    
    func viewAppeared() {
        Task {
            var model = await ShowsView.Model(
                isUserShowsLoaded: true,
                isPopularShowsLoaded: false,
                userShows: getUserShows(),
                popularShows: [])
            
            await setModel(model)
            
            let popularShows = try await tvService.getPopular()
            model.popularShows = popularShows.map { .init(id: $0.id, posterPath: $0.posterPath ?? "") }
            model.isPopularShowsLoaded = true
            
            await setModel(model)
        }
    }
    
    func reload() {
        Task {
            await setUserShows(getUserShows())
        }
    }
}

private extension ShowsViewModel {
    
    @MainActor
    func setModel(_ model: ShowsView.Model) {
        self.model = model
    }
    
    @MainActor
    func setUserShows(_ shows: [ShowsView.Model.UserShow]) {
        model.userShows = shows
    }
}

private extension ShowsViewModel {
    
    func getUserShows() async -> [ShowsView.Model.UserShow] {
        let savedShows = coreDataStorage.get(object: PlainShow.self)
        var userShows: [ShowsView.Model.UserShow] = []
        for show in savedShows {
            // TODO: make concurrent loading
            let image = (try? await imageService.loadImage(path: show.posterPath ?? "", width: 500).wrapInImage()) ?? Image("")
            userShows.append(.init(id: show.id, image: image))
        }
        return userShows
    }
}
