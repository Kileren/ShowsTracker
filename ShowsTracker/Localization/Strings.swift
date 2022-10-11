//
//  Strings.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.04.2021.
//

import Foundation

enum Strings {
    static let popular = string(forKey: "popular")
    static let more = string(forKey: "more")
    static let noTrackingShows = string(forKey: "noTrackingShows")
    static let add = string(forKey: "add")
    static let noDescription = string(forKey: "noDescription")
    static let ourTime = string(forKey: "ourTime")
    static let settings = string(forKey: "settings")
    static let iCloudSync = string(forKey: "iCloudSync")
    static let actualInfoOnAllDevices = string(forKey: "actualInfoOnAllDevices")
    static let archive = string(forKey: "archive")
    static let lookYourHistory = string(forKey: "lookYourHistory")
    static let look = string(forKey: "look")
    static let region = string(forKey: "region")
    static let regionDescription = string(forKey: "regionDescription")
    static let notificationsTitle = string(forKey: "notificationsTitle")
    static let notificationsDescription = string(forKey: "notificationsDescription")
    static let appThemeTitle = string(forKey: "appThemeTitle")
    static let appThemeDescription = string(forKey: "appThemeDescription")
    static let aboutAppTitle = string(forKey: "aboutAppTitle")
    static let aboutAppDescription = string(forKey: "aboutAppDescription")
    static let open = string(forKey: "open")
    static let filters = string(forKey: "filters")
    static let clear = string(forKey: "clear")
    static let releaseYear = string(forKey: "releaseYear")
    static let genres = string(forKey: "genres")
    static let all = string(forKey: "all")
    static let originalLanguage = string(forKey: "originalLanguage")
    static let any = string(forKey: "any")
    static let sortBy = string(forKey: "sortBy")
    static let confirm = string(forKey: "confirm")
    static let sortByPopularity = string(forKey: "sortByPopularity")
    static let sortByNovelty = string(forKey: "sortByNovelty")
    static let sortByRating = string(forKey: "sortByRating")
    static let search = string(forKey: "search")
    static let soon = string(forKey: "soon")
    static let ongoing = string(forKey: "ongoing")
    static let ended = string(forKey: "ended")
    static let inProduction = string(forKey: "inProduction")
    static let status = string(forKey: "status")
    static let season = string(forKey: "season")
    static let description = string(forKey: "description")
    static let episodes = string(forKey: "episodes")
    static let details = string(forKey: "details")
    static let similar = string(forKey: "similar")
    static let addToArchive = string(forKey: "addToArchive")
    static let addToArchiveHint = string(forKey: "addToArchiveHint")
    static let removeFromFavourites = string(forKey: "removeFromFavourites")
    static let cancel = string(forKey: "cancel")
    static let emptyArchive = string(forKey: "emptyArchive")
    static let backToFavourites = string(forKey: "backToFavourites")
    static let removeFromArchive = string(forKey: "removeFromArchive")
    
    static func genrePlural(_ count: Int) -> String {
        let format = NSLocalizedString("genre_plural", tableName: "Localization", comment: "")
        return String.localizedStringWithFormat(format, count)
    }
    
    static func string(forKey key: String) -> String {
        Bundle.main.localizedString(
            forKey: key,
            value: nil,
            table: "Localization")
    }
}
