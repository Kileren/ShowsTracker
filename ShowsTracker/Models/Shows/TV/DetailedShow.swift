//
//  DetailedShow.swift
//  ShowsTracker
//
//  Created by s.bogachev on 09.04.2021.
//

import SwiftUI

struct DetailedShow: Codable, Equatable {
    
    let posterPath: String?
    let backdropPath: String?
    let episodeRunTime: [Int]?
    let airDate: String?
    let genres: [Genre]?
    let homepage: String?
    let id: Int?
    let inProduction: Bool?
    let languages: [String]?
    let lastAirDate: String?
    let lastEpisode: LastEpisode?
    let name: String?
    let networks: [Network]?
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    let countries: [String]?
    let originalLanguage: String?
    let overview: String?
    let popularity: Double?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let status: Status?
    let tagline: String?
    private let voteOriginal: Double?
    private let voteCountOriginal: Int?
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case episodeRunTime = "episode_run_time"
        case airDate = "first_air_date"
        case genres
        case homepage
        case id
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisode = "last_episode_to_air"
        case name
        case networks
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case countries = "origin_country"
        case originalLanguage = "original_language"
        case overview
        case popularity
        case productionCountries = "production_countries"
        case seasons
        case status
        case tagline
        case voteOriginal = "vote_average"
        case voteCountOriginal = "vote_count"
    }
}

extension DetailedShow {
    struct Genre: Codable, Equatable {
        let id: Int?
        let name: String?
    }
}

extension DetailedShow {
    struct LastEpisode: Codable, Equatable {
        
        let airDate: String?
        let episodeNumber: Int?
        let id: Int?
        let name: String?
        let overview: String?
        let seasonNumber: Int?
        let stillPath: String?
        let vote: Double?
        
        enum CodingKeys: String, CodingKey {
            case airDate = "air_date"
            case episodeNumber = "episode_number"
            case id
            case name
            case overview
            case seasonNumber = "season_number"
            case stillPath = "still_path"
            case vote = "vote_average"
        }
    }
}

extension DetailedShow {
    struct Network: Codable, Equatable {
        
        let name: String?
        let id: Int?
        let logoPath: String?
        let country: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case id
            case logoPath = "logo_path"
            case country = "origin_country"
        }
    }
}

extension DetailedShow {
    struct ProductionCountry: Codable, Equatable {
        
        let isoCode: String?
        let name: String?
        
        enum CodingKeys: String, CodingKey {
            case isoCode = "iso_3166_1"
            case name
        }
    }
}

extension DetailedShow {
    struct Season: Codable, Equatable {
        
        let airDate: String?
        let episodeCount: Int?
        let id: Int?
        let name: String?
        let overview: String?
        let posterPath: String?
        let seasonNumber: Int?
        
        enum CodingKeys: String, CodingKey {
            case airDate = "air_date"
            case episodeCount = "episode_count"
            case id
            case name
            case overview
            case posterPath = "poster_path"
            case seasonNumber = "season_number"
        }
    }
}

extension DetailedShow {
    enum Status: Codable, Equatable, RawRepresentable {
        
        case ongoing
        case ended
        case inProduction
        case planned
        case unknown(String)
        
        init?(rawValue: String) {
            switch rawValue {
            case "Returning Series":
                self = .ongoing
            case "Ended":
                self = .ended
            case "In Production":
                self = .inProduction
            case "Planned":
                self = .planned
            default:
                self = .unknown(rawValue)
                assertionFailure("Unknown status - \(rawValue), add it")
            }
        }
        
        var rawValue: String {
            switch self {
            case .ongoing: return "Returning Series"
            case .ended: return "Ended"
            case .inProduction: return "In Production"
            case .planned: return "Planned"
            case .unknown(let value): return value
            }
        }
    }
}

extension DetailedShow {
    static let zero = DetailedShow(
        posterPath: nil,
        backdropPath: nil,
        episodeRunTime: nil,
        airDate: nil,
        genres: nil,
        homepage: nil,
        id: nil,
        inProduction: nil,
        languages: nil,
        lastAirDate: nil,
        lastEpisode: nil,
        name: nil,
        networks: nil,
        numberOfEpisodes: nil,
        numberOfSeasons: nil,
        countries: nil,
        originalLanguage: nil,
        overview: nil,
        popularity: nil,
        productionCountries: nil,
        seasons: nil,
        status: nil,
        tagline: nil,
        voteOriginal: nil,
        voteCountOriginal: nil)
}

// TODO: Just for test, remove it
extension DetailedShow {
    static func theWitcher() -> DetailedShow {
        do {
            return try JSONReader.object(forResource: "TheWitcherDetailed")
        } catch {
            fatalError("There's an error at json reader - \(error)")
        }
    }
    
    static func theMandalorian() -> DetailedShow {
        do {
            return try JSONReader.object(forResource: "TheMandalorianDetailed")
        } catch {
            fatalError("There's an error at json reader - \(error)")
        }
    }
}

extension DetailedShow {
    var releaseYear: String {
        if let date = airDate {
            return year(from: date) ?? ""
        }
        return ""
    }
    
    var lastEpisodeYear: String {
        if let date = lastAirDate {
            return year(from: date) ?? ""
        }
        return ""
    }
    
    var broadcastYears: String {
        if inProduction == true {
            return "\(releaseYear) - \(Strings.ourTime)"
        } else {
            return "\(releaseYear) - \(lastEpisodeYear)"
        }
    }
    
    var vote: String {
        guard let voteOriginal = voteOriginal else { return "" }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: voteOriginal)) ?? "\(voteOriginal)"
    }
    
    var voteCount: String {
        guard let voteCountOriginal = voteCountOriginal else { return "" }
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: voteCountOriginal)) ?? "\(voteCountOriginal)"
    }
}

private extension DetailedShow {
    func year(from string: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: string) else { return nil }
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}
