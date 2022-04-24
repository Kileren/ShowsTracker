//
//  TVTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import Foundation
import Moya

enum TVTarget {
    case details(id: Int)
}

extension TVTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/tv/")! }
    
    var path: String {
        switch self {
        case .details(let id):
            return "\(id)"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case .details:
            return .requestParameters(parameters: [:].withApiKey, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .details:
            do {
                return try JSONReader.data(forResource: "TheWitcherDetailed")
            } catch {
                Logger.log(error: error)
                return Data()
            }
        }
    }
}
