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
}

final class SearchService {
    
    @Injected private var inMemoryStorage: InMemoryStorageProtocol
    
    private let provider = MoyaProvider<SearchTarget>(stubClosure: { _ in isPreview ? .delayed(seconds: 0) : .never })
//    private let provider = MoyaProvider<SearchTarget>()
}

extension SearchService: ISearchService {
    
    func searchTVShows(query: String) async throws -> [PlainShow] {
        let result = await provider.request(target: .tv(query: query))
        
        switch result {
        case .success(let response):
            let shows = try parse(response: response, to: [PlainShow].self)
            inMemoryStorage.cacheShows(shows)
            return shows
        case .failure(let error):
            Logger.log(error: error)
            throw error
        }
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
}
