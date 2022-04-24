//
//  Network+Resolver.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Resolver

extension Resolver {
    static func registerNetworkServices() {
        register(ISearchService.self) { SearchService() }
        register(IImageService.self) { ImageService() }.scope(.application)
    }
}
