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
    
    func cache(seasonDetails: SeasonDetails, showID: Int, seasonNumber: Int)
    func getCachedSeasonDetails(showID: Int) -> [SeasonDetails]
    func getCachedSeasonDetails(showID: Int, seasonNumber: Int) -> SeasonDetails?
}

final class InMemoryStorage: InMemoryStorageProtocol {
    
    private var cachedShows: Set<PlainShow> = []
    private var cachedSeasonDetails: [Int: [Int: SeasonDetails]] = [:]
    
    private let showsLock = NSLock()
    private let seasonDetailsLock = NSLock()
    
    // MARK: - Show
    
    func cacheShow(_ show: PlainShow) {
        showsLock.lock()
        cachedShows.insert(show)
        showsLock.unlock()
    }
    
    func cacheShows(_ shows: [PlainShow]) {
        shows.forEach { cachedShows.insert($0) }
    }
    
    func getCachedShow(id: Int) -> PlainShow? {
        cachedShows.first { $0.id == id }
    }
    
    // MARK: - Season Details
    
    func cache(seasonDetails: SeasonDetails, showID: Int, seasonNumber: Int) {
        seasonDetailsLock.lock()
        if cachedSeasonDetails[showID] == nil {
            cachedSeasonDetails[showID] = [:]
        }
        cachedSeasonDetails[showID]?[seasonNumber] = seasonDetails
        seasonDetailsLock.unlock()
    }
    
    func getCachedSeasonDetails(showID: Int) -> [SeasonDetails] {
        cachedSeasonDetails[showID]?.values.map { $0 } ?? []
    }
    
    func getCachedSeasonDetails(showID: Int, seasonNumber: Int) -> SeasonDetails? {
        cachedSeasonDetails[showID]?[seasonNumber]
    }
}
