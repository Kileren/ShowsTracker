//
//  ShowsViewInteractor.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Foundation
import UIKit

final class ShowsViewInteractor {
    
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        appState.shows = [
            DetailedShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
            DetailedShow(imageData: UIImage(named: "TheMandalorian")?.pngData())
        ]
        
        appState.popularShows = [
            PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
            PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData()),
            PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
            PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData()),
            PlainShow(imageData: UIImage(named: "TheWitcher")?.pngData()),
            PlainShow(imageData: UIImage(named: "TheMandalorian")?.pngData())
        ]
    }
}
