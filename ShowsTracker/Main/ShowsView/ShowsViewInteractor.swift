//
//  ShowsViewInteractor.swift
//  ShowsTracker
//
//  Created by s.bogachev on 28.01.2021.
//

import Foundation
import UIKit
import SwiftUI
import Resolver

final class ShowsViewInteractor: ObservableObject {
    
    private var appState: AppState
    @Injected var imageService: IImageService
    
    private(set) var imagesForShow: [Int: Image] = [:]
    
    @Published var isCurrentLoaded: Bool = false
    @Published var isPopularLoaded: Bool = false
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func viewAppeared() {
        appState.shows = [.theWitcher(), .theMandalorian()]
        appState.shows.forEach { show in
            Task(priority: .high) {
                do {
                    let image = try await imageService.loadImage(path: show.posterPath ?? "", width: 500)
                    imagesForShow[show.id ?? 0] = image.wrapInImage()
                } catch {
                    Logger.log(warning: "Image not loaded and its not handled")
                }
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
