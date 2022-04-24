//
//  SearchServicePreview.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

#if DEBUG
import Foundation
import Moya

final class SearchServicePreview: ISearchService {
    func searchTVShows(query: String) async throws -> [PlainShow] {
        do {
            let data = try JSONReader.data(forResource: "WitcherSearch")
            let response = Response(statusCode: 200, data: data, request: nil, response: nil)
            let decoder = JSONDecoder()
            let result = try response.map([PlainShow].self, atKeyPath: "results", using: decoder)
            return result
        } catch {
            throw error
        }
    }
}
#endif
