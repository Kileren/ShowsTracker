//
//  TVService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import Foundation
import Moya
import Resolver

protocol ITVService {
    func getDetails(for showId: Int) async throws -> DetailedShow
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails
    func getSimilar(for showId: Int) async throws -> [PlainShow]
    func getPopular() async throws -> [PlainShow]
    func getMorePopular() async throws -> [PlainShow]
    func getByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow]
    func getMoreByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow]
    func getUpcoming() async throws -> [PlainShow]
    func getMoreUpcoming() async throws -> [PlainShow]
}

final class TVService {
    
    // Dependencies
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    
    // Providers
    private let tvProvider = MoyaProvider<TVTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
//    private let tvProvider = MoyaProvider<TVTarget>()
    private let discoverProvider = MoyaProvider<DiscoverTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
//    private let discoverProvider = MoyaProvider<DiscoverTarget>()
    
    // Pages
    private var popularShowsPage: Int = 1
    private var filteredShowsPage: [DiscoverTarget.Filter: Int] = [:]
    private var upcomingShowsPage: Int = 1
    
    // Cache
    private var cachedPopularShows: [PlainShow] = []
    private var cachedFilteredShows: [DiscoverTarget.Filter: [PlainShow]] = [:]
    private var cachedUpcomingShows: [PlainShow] = []
}

extension TVService: ITVService {
    
    func getDetails(for showId: Int) async throws -> DetailedShow {
        let result = await tvProvider.request(target: .details(id: showId))
        return try parse(result: result, to: DetailedShow.self)
    }
    
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails {
        let result = await tvProvider.request(target: .seasonDetails(id: showId, season: season))
        let seasonDetails = try parse(result: result, to: SeasonDetails.self)
        inMemoryStorage.cache(seasonDetails: seasonDetails, showID: showId, seasonNumber: season)
        return seasonDetails
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
            inMemoryStorage.cacheShows(shows)
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
        return try await getMoreByFilter(filter)
    }
    
    func getMoreByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow] {
        let result = await discoverProvider.request(target: .tv(filter: filter, page: filteredShowsPage[filter] ?? 1))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            cachedFilteredShows[filter]?.append(contentsOf: shows)
            inMemoryStorage.cacheShows(shows)
            filteredShowsPage[filter] = (filteredShowsPage[filter] ?? 0) + 1
            return shows
        } catch {
            throw error
        }
    }
    
    func getUpcoming() async throws -> [PlainShow] {
        guard cachedUpcomingShows.isEmpty else {
            return cachedUpcomingShows
        }
        return try await getMoreUpcoming()
    }
    
    func getMoreUpcoming() async throws -> [PlainShow] {
        let day: TimeInterval = 60 * 60 * 24
        let date = Date().addingTimeInterval(day)
        let upcomingFilter = DiscoverTarget.Filter(
            sortType: .popularity,
            minAirDate: STDateFormatter.format(date, format: .airDate))
        let result = await discoverProvider.request(target: .tv(filter: upcomingFilter, page: upcomingShowsPage))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            cachedUpcomingShows.append(contentsOf: shows)
            inMemoryStorage.cacheShows(shows)
            upcomingShowsPage += 1
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

extension TVService {
    enum InternalError: Error {
        case couldntGetDateComponents
    }
}
