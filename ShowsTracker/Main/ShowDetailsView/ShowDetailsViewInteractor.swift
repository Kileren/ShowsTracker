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
    @Injected var searchService: ISearchService
    @Injected var imageService: IImageService
    
    func viewAppeared() {
        show = appState.shows.first { $0.id == appState.detailedShowId } ?? .theWitcher()
        showIsLoaded = true
        
        Task {
            let shows = try? await searchService.searchTVShows(query: "The Witcher")
            let image = try? await imageService.loadImage(path: "/jBJWaqoSCiARWtfV0GlqHrcdidd.jpg", width: 500)
        }
    }
}
