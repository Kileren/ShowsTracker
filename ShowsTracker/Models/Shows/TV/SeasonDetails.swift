//
//  SeasonDetails.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 01.05.2022.
//

import Foundation

struct SeasonDetails: Codable {
    let name: String?
    let posterPath: String?
    let airDate: String?
    let overview: String?
    let episodes: [Episode]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case posterPath = "poster_path"
        case airDate = "air_date"
        case overview
        case episodes
    }
}

extension SeasonDetails {
    struct Episode: Codable {
        let airDate: String?
        let episodeNumber: Int?
        let name: String?
        let overview: String?
        
        enum CodingKeys: String, CodingKey {
            case airDate = "air_date"
            case episodeNumber = "episode_number"
            case name
            case overview
        }
    }
}
