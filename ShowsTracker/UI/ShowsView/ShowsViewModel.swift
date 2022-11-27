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
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    @Injected private var analyticsService: AnalyticsService
    
    func viewAppeared() {
        logStartupUserProperties()
        Task {
            let model = await ShowsView.Model(
                isUserShowsLoaded: true,
                userShows: getUserShows(),
                popularShowsState: .loading)
            await setModel(model)
            await reloadPopularShows()
        }
    }
    
    func reloadLikedShows() {
        Task {
            await setUserShows(getUserShows())
        }
    }
    
    func reloadPopularShows() async {
        await changeModel { $0.popularShowsState = .loading }
        do {
            let popularShows = try await tvService.getPopular()
            await changeModel {
                $0.popularShowsState = .loaded(
                    models: popularShows.map { .init(id: $0.id, posterPath: $0.posterPath ?? "") }
                )
            }
        } catch {
            await changeModel { $0.popularShowsState = .error }
        }
    }
    
    func reloadPopularShows() {
        Task {
            await reloadPopularShows()
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
    
    @MainActor
    func changeModel(handler: (inout ShowsView.Model) -> Void) {
        handler(&model)
    }
}

private extension ShowsViewModel {
    
    func getUserShows() async -> [ShowsView.Model.UserShow] {
        guard let shows = coreDataStorage.get(objectsOfType: Shows.self).first else { return [] }
        
        analyticsService.setUserProperty(property: .numberOfLikedShows(value: shows.likedShows.count))
        analyticsService.setUserProperty(property: .numberOfArchivedShows(value: shows.archivedShows.count))
        
        let likedShows = shows.likedShows
        inMemoryStorage.cacheShows(likedShows)
        var userShows: [ShowsView.Model.UserShow] = []
        for show in likedShows {
            // TODO: make concurrent loading
            let image = (try? await imageService.loadImage(path: show.posterPath ?? "").wrapInImage()) ?? Image("")
            userShows.append(.init(id: show.id, image: image))
        }
        return userShows
    }
    
    func logStartupUserProperties() {
        let languageValue = AppSettings<AppLanguageKey>.value(for: AppLanguageKey.self)
        let language = AppLanguage(rawValue: languageValue)
        let episodesTracking = AppSettings<EpisodesTrackingKey>.value(for: EpisodesTrackingKey.self)
        
        analyticsService.setUserProperty(property: .language(value: language))
        analyticsService.setUserProperty(property: .episodesTrackingEnabled(value: episodesTracking))
    }
}
