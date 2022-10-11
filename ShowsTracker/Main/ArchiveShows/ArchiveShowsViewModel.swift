//
//  ArchiveShowsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.10.2022.
//

import Foundation
import Resolver

final class ArchiveShowsViewModel: ObservableObject {
    
    @Published var model = ArchiveShowsModel()
    
    @Injected private var coreDataStorage: ICoreDataStorage
    
    func onAppear() {
        reload()
    }
    
    func reload() {
        let shows = coreDataStorage.get(objectsOfType: Shows.self).first ?? Shows()
        if shows.archivedShows.isEmpty {
            model.state = .empty
        } else {
            let models = shows.archivedShows.map { ShowView.Model(plainShow: $0) }
            model.state = .shows(shows: models)
        }
    }
}
