//
//  ShowsListModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 06.11.2022.
//

import Foundation

struct ShowsListModel {
    var chosenTab: Tab = .popular
    var filter: FilterView.Model = .empty
    var initiallyLoaded: Bool = false
    var currentRepresentation: Representation = .popular(state: .loading)
    var shows: [ShowView.Model] = []
    var tabIsVisible: Bool = true
    var filterButtonIsVisible: Bool = true
    var loadMoreAvailable: Bool = true
    var loadingMoreError = false
    
    enum Representation: Equatable {
        case popular(state: State)
        case filter(state: State)
        case upcoming(state: State)
        case search(state: State)
    }
    
    enum State: Equatable {
        case loading
        case loaded
        case error
    }
    
    enum Tab {
        case popular
        case soon
        
        var name: String {
            switch self {
            case .popular: return Strings.popular
            case .soon: return Strings.soon
            }
        }
    }
}

extension ShowsListModel {
    var state: State {
        switch currentRepresentation {
        case .popular(let state), .upcoming(let state), .filter(let state), .search(let state):
            return state
        }
    }
}
