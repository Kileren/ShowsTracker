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
    func getMorePopular() async throws -> [PlainShow]
    func getByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow]
    func getMoreByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow]
}

final class TVService {
    
    private let tvProvider = MoyaProvider<TVTarget>(stubClosure: { _ in .delayed(seconds: 1) })
//    private let tvProvider = MoyaProvider<TVTarget>()
    private let discoverProvider = MoyaProvider<DiscoverTarget>()
    
    private var cachedPopularShows: [PlainShow] = []
    private var popularShowsPage: Int = 1
    
    private var cachedFilteredShows: [DiscoverTarget.Filter: [PlainShow]] = [:]
    private var filteredShowsPage: [DiscoverTarget.Filter: Int] = [:]
}

extension TVService: ITVService {
    
    func getDetails(for showId: Int) async throws -> DetailedShow {
        let result = await tvProvider.request(target: .details(id: showId))
        return try parse(result: result, to: DetailedShow.self)
    }
    
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails {
        let result = await tvProvider.request(target: .seasonDetails(id: showId, season: season))
        return try parse(result: result, to: SeasonDetails.self)
    }
    
    func getSimilar(for showId: Int) async throws -> [PlainShow] {
        let result = await tvProvider.request(target: .similar(id: showId))
        return try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
    }
    
    func getPopular() async throws -> [PlainShow] {
        guard cachedPopularShows.isEmpty else {
            return cachedPopularShows
        }
        return try await getMorePopular()
    }
    
    func getMorePopular() async throws -> [PlainShow] {
        let result = await tvProvider.request(target: .popular(page: popularShowsPage))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            cachedPopularShows.append(contentsOf: shows)
            popularShowsPage += 1
            return shows
        } catch {
            throw error
        }
    }
    
    func getByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow] {
        if let shows = cachedFilteredShows[filter], !shows.isEmpty {
            return shows
        }
        cachedFilteredShows[filter] = []
        filteredShowsPage[filter] = 1
        return try await getMorePopular()
    }
    
    func getMoreByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow] {
        let result = await discoverProvider.request(target: .tv(filter: filter, page: filteredShowsPage[filter] ?? 1))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            cachedFilteredShows[filter]?.append(contentsOf: shows)
            filteredShowsPage[filter] = (filteredShowsPage[filter] ?? 0) + 1
            return shows
        } catch {
            throw error
        }
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
