//
//  ShowDetailsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 11.10.2022.
//

import Foundation

struct ShowDetailsModel: Equatable {
    var loading: Loading = .loading
    var posterPath = ""
    var name = ""
    var broadcastYears = ""
    var vote = ""
    var voteCount = ""
    var status: Status = .inProduction
    var isLiked = false
    var isArchived = false
    var selectedInfoTab: InfoTab = .episodes
    var detailsInfo = DetailsInfo()
    var seasonsInfo = [SeasonInfo]()
    var similarShowsInfo = SimilarShowsInfo()
    var removeShowAlertIsShown = false
    var archiveShowAlertIsShown = false
    
    enum Loading {
        case loading
        case done
        case error
    }
    
    enum Status {
        case ongoing
        case ended
        case inProduction
        case planned
        case canceled
    }
    
    enum InfoTab: String {
        case episodes
        case details
        case similar
        
        var rawValue: String {
            switch self {
            case .episodes: return Strings.episodes
            case .details: return Strings.details
            case .similar: return Strings.similar
            }
        }
    }
    
    struct DetailsInfo: Equatable {
        var tags: [String] = []
        var overview: String = ""
    }
    
    struct SeasonInfo: Equatable, Hashable {
        var seasonNumber = 0
        var posterPath: String = ""
        var title: String = ""
        var overview: String = ""
        var episodes: [Episode] = []
        var notificationStatus: NotificationStatus = .none
    }
    
    struct Episode: Equatable, Hashable {
        var episodeNumber = 0
        var name = ""
        var date = ""
        var overview = ""
    }
    
    struct SimilarShowsInfo: Equatable {
        var state: State = .initial
        
        enum State: Equatable {
            case initial
            case loading
            case loaded(models: [ShowView.Model])
            case error
        }
    }
    
    enum NotificationStatus {
        case on
        case off
        case none
    }
}
