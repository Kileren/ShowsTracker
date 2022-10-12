//
//  ShowDetailsModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 11.10.2022.
//

import Foundation

struct ShowDetailsModel: Equatable {
    var isLoaded = false
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
    var episodesInfo = EpisodesInfo()
    var similarShowsInfo = SimilarShowsInfo()
    var removeShowAlertIsShown = false
    var archiveShowAlertIsShown = false
    
    enum Status {
        case ongoing
        case ended
        case inProduction
        case planned
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
    
    struct EpisodesInfo: Equatable {
        var numberOfSeasons: Int = 0
        var selectedSeason = 0
        var episodesPerSeasons: [[Episode]] = []
        
        struct Episode: Equatable, Hashable {
            var episodeNumber = 0
            var name = ""
            var date = ""
            var overview = ""
        }
    }
    
    struct SimilarShowsInfo: Equatable {
        var isLoaded = false
        var models: [ShowView.Model] = []
    }
}
