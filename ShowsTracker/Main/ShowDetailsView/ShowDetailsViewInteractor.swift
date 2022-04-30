//
//  ShowDetailsViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import SwiftUI
import Resolver

final class ShowDetailsViewInteractor: ObservableObject {
    
    @InjectedObject var appState: AppState
    @Injected var tvService: ITVService
    
    private var showID: Int = 0
    
    func viewAppeared() {
        showID = appState.routing[\.showDetails.showID]
        
        Task {
            do {
                let show = try await tvService.getDetails(for: appState.routing[\.showDetails.showID])
                let model = ShowDetailsView.Model(
                    isLoaded: true,
                    posterPath: show.posterPath ?? "",
                    name: show.name ?? "",
                    broadcastYears: show.broadcastYears,
                    vote: show.vote,
                    voteCount: show.voteCount,
                    inProduction: show.inProduction ?? true,
                    isLiked: true)
                appState.info[\.showDetails[showID]] = model
            } catch {
                Logger.log(warning: "Detailed show not loaded and not handled")
            }
        }
    }
    
    func didTapLikeButton() {
        appState.info.value.showDetails[showID]?.isLiked.toggle()
    }
}
