//
//  SearchService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Foundation
import Moya

protocol ISearchService {
    func searchTVShows(query: String) async throws -> [PlainShow]
}

final class SearchService {
    
//    private let provider = MoyaProvider<SearchTarget>(stubClosure: { _ in .delayed(seconds: 0) })
    private let provider = MoyaProvider<SearchTarget>()
}

extension SearchService: ISearchService {
    
    func searchTVShows(query: String) async throws -> [PlainShow] {
        let result = await provider.request(target: .tv(query: query))
        
        switch result {
        case .success(let response):
            return try parse(response: response, to: [PlainShow].self)
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
