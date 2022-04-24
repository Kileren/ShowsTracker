//
//  SearchTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.04.2022.
//

import Foundation
import Moya

enum SearchTarget {
    case tv(query: String)
}

extension SearchTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/")! }
    
    var path: String {
        "search/tv"
    }
    
    var method: Moya.Method {
        switch self {
        case .tv:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .tv(let query):
            return .requestParameters(parameters: ["query": query].withApiKey, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .tv:
            do {
                return try JSONReader.data(forResource: "WitcherSearch")
            } catch {
                Logger.log(error: error)
                return Data()
            }
        }
    }
}
