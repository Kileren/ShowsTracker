//
//  GenresService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import Foundation
import Moya

protocol IGenresService {
    var cachedGenres: [Genre] { get }
    
    func getTVGenres() async throws -> [Genre]
}

final class GenresService {
    
    private let provider = MoyaProvider<GenresTarget>(stubClosure: { _ in .delayed(seconds: 1) })
//    private let provider = MoyaProvider<GenresTarget>()
    
    var cachedGenres: [Genre] = []
}

extension GenresService: IGenresService {
    
    func getTVGenres() async throws -> [Genre] {
        let result = await provider.request(target: .tv)
        switch result {
        case .success(let response):
            let decoded = try response.map([Genre].self, atKeyPath: "genres", using: JSONDecoder())
            Logger.log(response: response, parsedTo: [Genre].self)
            cachedGenres = decoded
            return decoded
        case .failure(let error):
            Logger.log(error: error, response: error.response)
            throw error
        }
    }
}
