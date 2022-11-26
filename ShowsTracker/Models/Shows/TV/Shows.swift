//
//  Shows.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 08.10.2022.
//

import Foundation
import CoreData

struct Shows: Codable {
    var likedShows: [PlainShow] = []
    var archivedShows: [PlainShow] = []
    var watchedEpisodes: [String] = []

    var id: Int = 0
}

extension Shows: ManagedObjectEncodable {
    typealias ManagedObject = ShowsMO
}

extension ShowsMO: ManagedObjectDecodable {
    typealias Object = Shows
    
    var object: Shows {
        get {
            Shows(likedShows: (likedShows?.array as? [PlainShowMO])?.map { $0.object } ?? [],
                  archivedShows: (archivedShows?.array as? [PlainShowMO])?.map { $0.object } ?? [],
                  watchedEpisodes: watchedEpisodes ?? [])
        }
        set {
            guard let context = managedObjectContext else { return }
            
            likedShows = []
            archivedShows = []
            
            for show in newValue.likedShows {
                let moShow = PlainShowMO(context: context)
                moShow.object = show
                addToLikedShows(moShow)
            }
            
            for show in newValue.archivedShows {
                let moShow = PlainShowMO(context: context)
                moShow.object = show
                addToArchivedShows(moShow)
            }
            
            watchedEpisodes = newValue.watchedEpisodes
        }
    }
}
