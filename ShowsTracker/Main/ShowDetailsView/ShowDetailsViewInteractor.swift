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
    @Injected var tvService: ITVService
    
    func viewAppeared() {
        show = appState.shows.first { $0.id == appState.detailedShowId } ?? .theWitcher()
        showIsLoaded = true
        
        Task {
            let detailedShow = try? await tvService.getDetails(for: show.id ?? 0)
            print(detailedShow)
        }
    }
}
