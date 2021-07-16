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
    
    @Injected var imageLoader: ImageLoader
    
    private var appState: AppState
    private var input: ShowDetailsView.Input?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared(with input: ShowDetailsView.Input) {
        self.input = input
        
        show = .theWitcher()
        showIsLoaded = true
    }
}

extension ShowDetailsView {
    enum Input {
        case plain(show: PlainShow)
        case detailed(show: DetailedShow)
    }
}
