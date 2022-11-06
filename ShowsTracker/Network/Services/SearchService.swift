//
//  SearchService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Foundation
import Moya
import Resolver

protocol ISearchService {
    func searchTVShows(query: String) async throws -> [PlainShow]
    func loadMoreTVShows() async throws -> [PlainShow]
    func canLoadMoreTVShows() -> Bool
}

final class SearchService {
    
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    
    private let provider = MoyaProvider<SearchTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
    
    private var lastQuery: String = ""
    private var lastQueryCurrentPage: Int = 1
    private var lastQueryTotalPages: Int = Int.max
}

extension SearchService: ISearchService {
    
    func searchTVShows(query: String) async throws -> [PlainShow] {
        lastQuery = query
        lastQueryCurrentPage = 1
        lastQueryTotalPages = Int.max
        return try await loadMoreTVShows()
    }
    
    func loadMoreTVShows() async throws -> [PlainShow] {
        guard lastQueryCurrentPage <= lastQueryTotalPages else {
            throw InternalError.allShowsLoaded
        }
        
        let result = await provider.request(target: .tv(query: lastQuery, page: lastQueryCurrentPage))
        switch result {
        case .success(let response):
            let shows = try parse(response: response, to: [PlainShow].self)
            inMemoryStorage.cacheShows(shows)
            lastQueryCurrentPage += 1
            lastQueryTotalPages = totalPages(from: response) ?? lastQueryTotalPages
            return shows
        case .failure(let error):
            Logger.log(error: error)
            throw error
        }
    }
    
    func canLoadMoreTVShows() -> Bool {
        lastQueryCurrentPage <= lastQueryTotalPages
    }
}

private extension SearchService {
    func parse<T: Decodable>(response: Response, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            let result = try response.map(type, atKeyPath: "results", using: decoder)
            Logger.log(response: response, parsedTo: [PlainShow].self)
            return result
        } catch {
            Logger.log(error: error, response: response)
            throw error
        }
    }
    
    func totalPages(from response: Response) -> Int? {
        try? response.map(Int.self, atKeyPath: "total_pages", using: JSONDecoder())
    }
}

extension SearchService {
    enum InternalError: Error {
        case allShowsLoaded
    }
}
