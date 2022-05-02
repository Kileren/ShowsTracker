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
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case .details, .seasonDetails:
            return .requestParameters(parameters: [:].withApiKey, encoding: URLEncoding.queryString)
        case .similar(let id):
            return .requestParameters(parameters: ["tv_id": id].withApiKey, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .details(let id):
            do {
                if id == 82856 {
                    return try JSONReader.data(forResource: "TheMandalorianDetailed")
                }
                return try JSONReader.data(forResource: "TheWitcherDetailed")
            } catch {
                Logger.log(error: error)
                return Data()
            }
        case .seasonDetails(_, let season):
            do {
                if season == 1 {
                    return try JSONReader.data(forResource: "TVSeasons_Details_s1")
                }
                return try JSONReader.data(forResource: "TVSeasons_Details_s2")
            } catch {
                Logger.log(error: error)
                return Data()
            }
        case .similar:
            do {
                return try JSONReader.data(forResource: "Similar_Witcher")
            } catch {
                Logger.log(error: error)
                return Data()
            }
        }
    }
}
