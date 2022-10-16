//
//  InMemoryStorage.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import Foundation

protocol InMemoryStorageProtocol {
    func cacheShow(_ show: PlainShow)
    func cacheShows(_ shows: [PlainShow])
    func getCachedShow(id: Int) -> PlainShow?
}

final class InMemoryStorage: InMemoryStorageProtocol {
    
    private var cachedShows: Set<PlainShow> = []
    
    func cacheShow(_ show: PlainShow) {
        cachedShows.insert(show)
    }
    
    func cacheShows(_ shows: [PlainShow]) {
        shows.forEach { cachedShows.insert($0) }
    }
    
    func getCachedShow(id: Int) -> PlainShow? {
        cachedShows.first { $0.id == id }
    }
}
