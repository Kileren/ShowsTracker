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
        let currentShowsCount = model.userShows.count
        let animationIsNeeded = currentShowsCount < 2 || (currentShowsCount == 2 && shows.count == 1)
        
        if animationIsNeeded {
            withAnimation(.easeInOut(duration: 0.25)) {
                model.userShows = shows
            }
        } else {
            model.userShows = shows
        }
    }
}

private extension ShowsViewModel {
    
    func getUserShows() async -> [ShowsView.Model.UserShow] {
        let likedShows = coreDataStorage.get(objectsOfType: Shows.self).first?.likedShows ?? []
        var userShows: [ShowsView.Model.UserShow] = []
        for show in likedShows {
            // TODO: make concurrent loading
            let image = (try? await imageService.loadImage(path: show.posterPath ?? "").wrapInImage()) ?? Image("")
            userShows.append(.init(id: show.id, image: image))
        }
        return userShows
    }
}
