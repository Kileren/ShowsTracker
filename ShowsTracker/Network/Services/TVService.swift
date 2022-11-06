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
    var canLoadMorePopular: Bool { get }
    var canLoadMoreByFilter: Bool { get }
    var canLoadMoreUpcoming: Bool { get }
    
    func getDetails(for showId: Int) async throws -> DetailedShow
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails
    func getSimilar(for showId: Int) async throws -> [PlainShow]
    func getPopular() async throws -> [PlainShow]
    func getMorePopular() async throws -> [PlainShow]
    func getByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow]
    func getMoreByFilter() async throws -> [PlainShow]
    func getUpcoming() async throws -> [PlainShow]
    func getMoreUpcoming() async throws -> [PlainShow]
}

final class TVService {
    
    // Dependencies
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    @Injected private var coreDataStorage: ICoreDataStorage
    
    // Providers
    private let tvProvider = MoyaProvider<TVTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
    private let discoverProvider = MoyaProvider<DiscoverTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
    
    // Pages
    private var popularShowsPage: Int = 1
    private var filterShowsPage: Int = 1
    private var upcomingShowsPage: Int = 1
    
    private var popularShowsTotalPages: Int = Int.max
    private var filterShowsTotalPages: Int = Int.max
    private var upcomingShowsTotalPages: Int = Int.max
    
    // Cache
    private var cachedPopularShows: [PlainShow] = []
    private var cachedUpcomingShows: [PlainShow] = []
    
    private var lastFilter: DiscoverTarget.Filter = .default
}

extension TVService: ITVService {
    
    var canLoadMorePopular: Bool { popularShowsPage <= popularShowsTotalPages }
    var canLoadMoreUpcoming: Bool { upcomingShowsPage <= upcomingShowsTotalPages }
    var canLoadMoreByFilter: Bool { filterShowsPage <= filterShowsTotalPages }
    
    func getDetails(for showId: Int) async throws -> DetailedShow {
        let result = await tvProvider.request(target: .details(id: showId))
        let show = try parse(result: result, to: DetailedShow.self)
        refreshSavedInfo(basedOn: show)
        return show
    }
    
    func getSeasonDetails(for showId: Int, season: Int) async throws -> SeasonDetails {
        let result = await tvProvider.request(target: .seasonDetails(id: showId, season: season))
        let seasonDetails = try parse(result: result, to: SeasonDetails.self)
        inMemoryStorage.cache(seasonDetails: seasonDetails, showID: showId, seasonNumber: season)
        return seasonDetails
    }
    
    func getSimilar(for showId: Int) async throws -> [PlainShow] {
        let result = await tvProvider.request(target: .similar(id: showId))
        let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
        inMemoryStorage.cacheShows(shows)
        return shows
    }
    
    func getPopular() async throws -> [PlainShow] {
        guard cachedPopularShows.isEmpty else {
            return cachedPopularShows
        }
        return try await getMorePopular()
    }
    
    func getMorePopular() async throws -> [PlainShow] {
        guard canLoadMorePopular else {
            throw InternalError.allShowsLoaded
        }
        
        let result = await tvProvider.request(target: .popular(page: popularShowsPage))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            popularShowsTotalPages = min(totalPages(from: result) ?? popularShowsPage, Int.max)
            cachedPopularShows.append(contentsOf: shows)
            inMemoryStorage.cacheShows(shows)
            popularShowsPage += 1
            return shows
        } catch {
            throw error
        }
    }
    
    func getByFilter(_ filter: DiscoverTarget.Filter) async throws -> [PlainShow] {
        lastFilter = filter
        filterShowsPage = 1
        filterShowsTotalPages = Int.max
        return try await getMoreByFilter()
    }
    
    func getMoreByFilter() async throws -> [PlainShow] {
        guard canLoadMoreByFilter else {
            throw InternalError.allShowsLoaded
        }
        
        let target = DiscoverTarget.tv(filter: lastFilter, page: filterShowsPage)
        let result = await discoverProvider.request(target: target)
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            inMemoryStorage.cacheShows(shows)
            filterShowsPage += 1
            filterShowsTotalPages = totalPages(from: result) ?? filterShowsTotalPages
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
        guard canLoadMoreUpcoming else {
            throw InternalError.allShowsLoaded
        }
        
        let day: TimeInterval = 60 * 60 * 24
        let date = Date().addingTimeInterval(day)
        let upcomingFilter = DiscoverTarget.Filter(
            sortType: .popularity,
            minAirDate: STDateFormatter.format(date, format: .airDate))
        let result = await discoverProvider.request(target: .tv(filter: upcomingFilter, page: upcomingShowsPage))
        do {
            let shows = try parse(result: result, to: [PlainShow].self, atKeyPath: "results")
            upcomingShowsTotalPages = totalPages(from: result) ?? upcomingShowsTotalPages
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
    
    func totalPages(from result: Result<Response, MoyaError>) -> Int? {
        if case .success(let response) = result {
            return (try? response.map(Int.self, atKeyPath: "total_pages", using: JSONDecoder())) ?? 0
        }
        return nil
    }
    
    func refreshSavedInfo(basedOn detailedShow: DetailedShow) {
        guard var shows = coreDataStorage.get(objectsOfType: Shows.self).first else { return }
        
        let findAndChangeIfNeeded: (WritableKeyPath<Shows, [PlainShow]>) -> Void = { keyPath in
            if let index = shows[keyPath: keyPath].firstIndex(where: { $0.id == detailedShow.id }) {
                shows[keyPath: keyPath][index].posterPath = detailedShow.posterPath
            }
        }
        findAndChangeIfNeeded(\.likedShows)
        findAndChangeIfNeeded(\.archivedShows)
        
        coreDataStorage.save(object: shows)
    }
}

extension TVService {
    enum InternalError: Error {
        case couldntGetDateComponents
        case allShowsLoaded
    }
}

private extension PlainShow {
    init(detailedShow: DetailedShow) {
        self.name = detailedShow.name
        self.originalName = detailedShow.originalName
        self.vote = detailedShow.voteOriginal
        self.posterPath = detailedShow.posterPath
        self.popularity = detailedShow.popularity
        self.id = detailedShow.id ?? 0
        self.backdropPath = detailedShow.backdropPath
        self.overview = detailedShow.overview
        self.airDate = detailedShow.airDate
        self.countries = detailedShow.countries
        self.genres = detailedShow.genres?.compactMap { $0.id }
        self.originalLanguage = detailedShow.originalLanguage
    }
}
