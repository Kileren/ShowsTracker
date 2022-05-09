//
//  ShowsListViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.05.2022.
//

import SwiftUI
import Resolver

final class ShowsListViewInteractor {
    
    @InjectedObject private var appState: AppState
    @Injected private var tvService: ITVService
    @Injected private var searchService: ISearchService
    
    func viewAppeared() {
        Task {
            do {
                let popularShows = try await tvService.getPopular().map {
                    ShowView.Model(
                        id: $0.id,
                        posterPath: $0.posterPath ?? "",
                        name: $0.name ?? "",
                        vote: STNumberFormatter.format($0.vote ?? 0, format: .vote))
                }
                let model = ShowsListView.Model(
                    isLoaded: true,
                    chosenTab: .popular,
                    popularShows: popularShows)
                self.setModel(model)
            } catch {
                Logger.log(warning: "Popular shows not loaded and not handled")
            }
        }
    }
    
    func searchShows(query: String) {
        Task {
            do {
                let shows = try await searchService.searchTVShows(query: query)
                print(shows)
            } catch {
                Logger.log(warning: "Shows not loaded after search and not handled")
            }
        }
    }
}

// MARK: - Private

private extension ShowsListViewInteractor {
    @MainActor
    func setModel(_ model: ShowsListView.Model) {
        appState.info[\.showsList] = model
    }
}
