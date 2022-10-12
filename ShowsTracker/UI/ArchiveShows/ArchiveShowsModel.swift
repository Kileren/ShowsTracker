//
//  ArchiveShowsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.10.2022.
//

import Foundation

struct ArchiveShowsModel {
    
    var state: State = .loading
    
    enum State {
        case loading
        case empty
        case shows(shows: [ShowView.Model])
    }
}
