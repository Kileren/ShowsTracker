//
//  TVService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import Foundation
import Moya

protocol ITVService {
    func getDetails(for showId: Int) async throws -> DetailedShow
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails
    func getSimilar(for showId: Int) async throws -> [PlainShow]
    func getPopular() async throws -> [PlainShow]
}

final class TVService {
    
    private let provider = MoyaProvider<TVTarget>(stubClosure: { _ in .delayed(seconds: 0) })
//    private let provider = MoyaProvider<TVTarget>()
}

extension TVService: ITVService {
    
    func getDetails(for showId: Int) async throws -> DetailedShow {
        let result = await provider.request(target: .details(id: showId))
        return try parse(result: result, to: DetailedShow.self)
    }
    
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails {
        let result = await provider.request(target: .seasonDetails(id: showId, season: season))
        return try parse(result: result, to: SeasonDetails.self)
    }
    
    func getSimilar(for showId: Int) async throws -> [PlainShow] {
        let result = await provider.request(target: .similar(id: showId))
        return try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
    }
    
    func getPopular() async throws -> [PlainShow] {
        let result = await provider.request(target: .popular)
        return try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
    }
}

private extension TVService {
    
    func parse<T: Decodable>(result: Result<Response, MoyaError>, to type: T.Type, atKeyPath keyPath: String? = nil) throws -> T {
        switch result {
        case .success(let response):
            let decoded = try response.map(T.self, atKeyPath: keyPath, using: JSONDecoder())
            Logger.log(response: response, parsedTo: T.self)
            return decoded
        case .failure(let error):
            Logger.log(error: error, response: error.response)
            throw error
        }
    }
}
