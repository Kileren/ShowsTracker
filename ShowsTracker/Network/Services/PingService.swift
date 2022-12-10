//
//  PingService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 10.12.2022.
//

import Foundation
import Moya

protocol IPingService {
    func ping() async -> Bool
}

final class PingService: IPingService {
    
    private let provider = MoyaProvider<PingTarget>()
    
    func ping() async -> Bool {
        let result = await provider.request(target: .ping)
        switch result {
        case .success:
            return true
        case .failure(let moyaError):
            if case let .underlying(error, _) = moyaError, let afError = error.asAFError, afError.isSessionTaskError {
                return false
            }
            return true
        }
    }
}
