//
//  UpdatesModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 06.05.2023.
//

import Foundation

struct UpdatesModel {
    
    var state: State = .loading
    
    enum State {
        case loading
        case updated(models: [UpdatedShowsView.Model])
        case updatesNotFound(lastCheck: String)
    }
}
