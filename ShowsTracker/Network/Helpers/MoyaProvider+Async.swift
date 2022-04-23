//
//  MoyaProvider+Async.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Moya

extension MoyaProvider {
    func request(target: Target) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
