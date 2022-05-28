//
//  GenresTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import Foundation
import Moya

enum GenresTarget {
    case tv
}

extension GenresTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/genre/")! }
    
    var path: String {
        "tv/list"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        .requestParameters(parameters: [:].withApiKey, encoding: URLEncoding.queryString)
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        do {
            return try JSONReader.data(forResource: "TVGenres")
        } catch {
            Logger.log(error: error)
            return Data()
        }
    }
}
