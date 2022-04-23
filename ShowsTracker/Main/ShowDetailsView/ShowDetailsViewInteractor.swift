//
//  ShowDetailsViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import SwiftUI
import Resolver

final class ShowDetailsViewInteractor: ObservableObject {
    
    @Published var show: DetailedShow = .zero
    @Published var showIsLoaded: Bool = false
    
    @InjectedObject var appState: AppState
    @Injected var imageLoader: ImageLoader
    @Injected var searchService: ISearchService
    
    func viewAppeared() {
        show = appState.shows.first { $0.id == appState.detailedShowId } ?? .theWitcher()
        showIsLoaded = true
        
        Task {
            let shows = try? await searchService.searchTVShows(query: "The Witcher")
        }
    }
}
