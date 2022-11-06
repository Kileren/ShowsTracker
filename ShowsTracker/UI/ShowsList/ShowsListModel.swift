//
//  ShowsListModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 06.11.2022.
//

import Foundation

struct ShowsListModel {
    var isLoaded: Bool = false
    var chosenTab: Tab = .popular
    var filter: FilterView.Model = .empty
    var currentRepresentation: Representation = .popular
    var shows: [ShowView.Model] = []
    var tabIsVisible: Bool = true
    var filterButtonIsVisible: Bool = true
    var loadMoreSpinnerIsVisible: Bool = true
    
    enum Representation: Equatable {
        case popular
        case filter
        case upcoming
        case search
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
