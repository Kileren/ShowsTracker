//
//  DiscoverTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 10.06.2022.
//

import Foundation
import Moya

enum DiscoverTarget {
    case tv(filter: Filter, page: Int)
}

extension DiscoverTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/discover/")! }
    
    var path: String {
        "tv"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case let .tv(filter, page):
            var parameters: [String: Any] = [:]
            parameters["page"] = page
            parameters["include_null_first_air_dates"] = false
            parameters["sort_by"] = filter.sortType.rawValue
            if !filter.genres.isEmpty { parameters["with_genres"] = filter.genres.joined(separator: ",") }
            filter.originalLanguage.flatMap { parameters["with_original_language"] = $0 }
            filter.minAirYear.flatMap { parameters["air_date.gte"] = "\($0)-01-01" }
            filter.maxAirYear.flatMap { parameters["air_date.lte"] = "\($0)-01-01" }
            
            return .requestParameters(
                parameters: parameters.withApiKey,
                encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
}

extension DiscoverTarget {
    struct Filter: Hashable {
        let sortType: SortType
        let genres: [String]
        let originalLanguage: LangCode?
        let minAirYear: Int?
        let maxAirYear: Int?
        
        init(sortType: SortType,
             genres: [String],
             originalLanguage: LangCode? = nil,
             minAirYear: Int? = nil,
             maxAirYear: Int? = nil) {
            self.sortType = sortType
            self.genres = genres
            self.originalLanguage = originalLanguage
            self.minAirYear = minAirYear
            self.maxAirYear = maxAirYear
        }
    }
    
    enum SortType: String {
        case popularity = "popularity.desc"
        case airDate = "first_air_date.desc"
        case votes = "vote_average.desc"
    }
}
