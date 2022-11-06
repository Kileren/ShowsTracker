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
            if !filter.genres.isEmpty { parameters["with_genres"] = filter.genres.map { "\($0)" }.joined(separator: ",") }
            filter.originalLanguage.flatMap { parameters["with_original_language"] = $0 }
            filter.minAirDate.flatMap { parameters["first_air_date.gte"] = $0 }
            filter.maxAirDate.flatMap { parameters["first_air_date.lte"] = $0 }
            
            return .requestParameters(
                parameters: parameters.withApiKey,
                encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        do {
            switch self {
            case let .tv(_, page):
                if page == 1 {
                    return try JSONReader.data(forResource: "discover_tv_1")
                }
                return try JSONReader.data(forResource: "discover_tv_2")
            }
        } catch {
            Logger.log(error: error)
            return Data()
        }
    }
}

extension DiscoverTarget {
    struct Filter: Hashable {
        let sortType: SortType
        let genres: Set<Int>
        let originalLanguage: LangCode?
        let minAirDate: String?
        let maxAirDate: String?
        
        init(sortType: SortType,
             genres: Set<Int> = [],
             originalLanguage: LangCode? = nil,
             minAirYear: Int? = nil,
             maxAirYear: Int? = nil) {
            self.sortType = sortType
            self.genres = genres
            self.originalLanguage = originalLanguage
            
            if let minAirYear = minAirYear {
                self.minAirDate = "\(minAirYear)-01-01"
            } else {
                self.minAirDate = nil
            }
            
            if let maxAirYear = maxAirYear {
                self.maxAirDate = "\(maxAirYear)-01-01"
            } else {
                self.maxAirDate = nil
            }
        }
        
        init(sortType: SortType,
             genres: Set<Int> = [],
             originalLanguage: LangCode? = nil,
             minAirDate: String? = nil,
             maxAirDate: String? = nil) {
            self.sortType = sortType
            self.genres = genres
            self.originalLanguage = originalLanguage
            self.minAirDate = minAirDate
            self.maxAirDate = maxAirDate
        }
        
        static let `default` = Filter(sortType: .popularity, genres: [], originalLanguage: nil, minAirYear: nil, maxAirYear: nil)
    }
    
    enum SortType: String {
        case popularity = "popularity.desc"
        case airDate = "first_air_date.desc"
        case votes = "vote_average.desc"
        case popularityAscending = "popularity.asc"
        case airDateAscending = "first_air_date.asc"
        case votesAscending = "vote_average.asc"
    }
}
