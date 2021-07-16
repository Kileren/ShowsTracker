//
//  ShowsViewInteractor.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Foundation
import UIKit
import SwiftUI

final class ShowsViewInteractor: ObservableObject {
    
    private var appState: AppState
    private(set) var imagesForShow: [Int: Image] = [:]
    
    @Published var isCurrentLoaded: Bool = false
    @Published var isPopularLoaded: Bool = false
    
    private let imageLoader: ImageLoader
    
    init(appState: AppState,
         imageLoader: ImageLoader) {
        self.appState = appState
        self.imageLoader = imageLoader
    }
    
    func viewAppeared() {
        appState.shows = [.theWitcher(), .theMandalorian()]
        appState.shows.forEach { show in
            async {
                let image = await imageLoader.obtainImage(ofType: .poster, from: show)
                imagesForShow[show.id ?? 0] = image.wrapInImage()
            }
        }
        
        appState.popularShows = [
            .theWitcher(), .theMandalorian(), .theWitcher(), .theMandalorian(), .theWitcher(), .theMandalorian()
        ]
        
        // TODO: Remove it later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isCurrentLoaded = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.isPopularLoaded = true
            }
        }
    }
}
