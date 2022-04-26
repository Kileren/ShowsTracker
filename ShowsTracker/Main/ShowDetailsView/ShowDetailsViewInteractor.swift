//
//  ShowDetailsViewInteractor.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import SwiftUI
import Resolver

final class ShowDetailsViewInteractor: ObservableObject {
    
//    @Published var show: DetailedShow = .zero
//    @Published var showIsLoaded: Bool = false
    
    @InjectedObject var appState: AppState
    @Injected var tvService: ITVService
    
    func viewAppeared() {
        Task {
            do {
                appState.showDetails.show = try await tvService.getDetails(for: appState.showDetails.id)
                appState.showDetails.isLoaded = true
            } catch {
                Logger.log(warning: "Detailed show not loaded and not handled")
            }
        }
    }
}
