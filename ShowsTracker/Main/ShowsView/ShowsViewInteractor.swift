//
//  ShowsViewInteractor.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Foundation
import UIKit

final class ShowsViewInteractor: ObservableObject {
    
    private var appState: AppState
    
    @Published var isCurrentLoaded: Bool = false
    @Published var isPopularLoaded: Bool = false
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        appState.shows = [
            DetailedShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
            DetailedShow(imageData: UIImage(named: "TheMandalorian")?.pngData())
        ]
        
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
