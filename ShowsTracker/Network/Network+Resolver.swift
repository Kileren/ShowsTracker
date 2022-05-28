//
//  Network+Resolver.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 21.04.2022.
//

import Resolver

extension Resolver {
    static func registerNetworkServices() {
        register(ISearchService.self) { SearchService() }.scope(.application)
        register(IImageService.self) { ImageService() }.scope(.application)
        register(ITVService.self) { TVService() }.scope(.application)
        register(IGenresService.self) { GenresService() }.scope(.application)
    }
}
