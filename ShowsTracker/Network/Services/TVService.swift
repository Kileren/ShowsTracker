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
}

final class TVService {
    
    private let provider = MoyaProvider<TVTarget>(stubClosure: { _ in .delayed(seconds: 1) })
}

extension TVService: ITVService {
    
    func getDetails(for showId: Int) async throws -> DetailedShow {
        
        let result = await provider.request(target: .details(id: showId))
        
        switch result {
        case .success(let response):
            let show = try response.map(DetailedShow.self)
            Logger.log(response: response, parsedTo: DetailedShow.self)
            return show
        case .failure(let error):
            Logger.log(error: error)
            throw error
        }
    }
}
