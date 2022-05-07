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
    case seasonDetails(id: Int, season: Int)
    case similar(id: Int)
    case popular
}

extension TVTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/tv/")! }
    
    var path: String {
        switch self {
        case .details(let id):
            return "\(id)"
        case .seasonDetails(let id, let season):
            return "\(id)/season/\(season)"
        case .similar(let id):
            return "\(id)/recommendations"
        case .popular:
            return "popular"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case .details, .seasonDetails, .popular:
            return .requestParameters(parameters: [:].withApiKey, encoding: URLEncoding.queryString)
        case .similar(let id):
            return .requestParameters(parameters: ["tv_id": id].withApiKey, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        do {
            switch self {
            case .details(let id):
                if id == 82856 {
                    return try JSONReader.data(forResource: "TheMandalorianDetailed")
                }
                return try JSONReader.data(forResource: "TheWitcherDetailed")
            case .seasonDetails(_, let season):
                if season == 1 {
                    return try JSONReader.data(forResource: "TVSeasons_Details_s1")
                }
                return try JSONReader.data(forResource: "TVSeasons_Details_s2")
            case .similar:
                return try JSONReader.data(forResource: "Similar_Witcher")
            case .popular:
                return try JSONReader.data(forResource: "tv_popular")
            }
        } catch {
            Logger.log(error: error)
            return Data()
        }
    }
}
