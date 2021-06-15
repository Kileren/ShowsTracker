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
    private let input: ShowDetailsView.Input
    
    init(appState: AppState,
         input: ShowDetailsView.Input) {
        
        self.appState = appState
        self.input = input
    }
    
    func viewAppeared() {
        show = DetailedShow(imageData: UIImage(named: "TheWitcher")?.pngData())
        showIsLoaded = true
    }
}

extension ShowDetailsView {
    enum Input {
        case plain(show: PlainShow)
        case detailed(show: DetailedShow)
    }
}
