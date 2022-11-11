//
//  Strings.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.04.2021.
//

import Foundation

enum Strings {
    static let aboutAppDescription = string(forKey: "aboutAppDescription")
    static let aboutAppTitle = string(forKey: "aboutAppTitle")
    static let actualInfoOnAllDevices = string(forKey: "actualInfoOnAllDevices")
    static let add = string(forKey: "add")
    static let addToArchive = string(forKey: "addToArchive")
    static let addToArchiveHint = string(forKey: "addToArchiveHint")
    static let all = string(forKey: "all")
    static let allow = string(forKey: "allow")
    static let any = string(forKey: "any")
    static let appThemeDescription = string(forKey: "appThemeDescription")
    static let appThemeTitle = string(forKey: "appThemeTitle")
    static let archive = string(forKey: "archive")
    static let backToFavourites = string(forKey: "backToFavourites")
    static let cancel = string(forKey: "cancel")
    static let clear = string(forKey: "clear")
    static let close = string(forKey: "close")
    static let confirm = string(forKey: "confirm")
    static let description = string(forKey: "description")
    static let details = string(forKey: "details")
    static let done = string(forKey: "done")
    static let edit = string(forKey: "edit")
    static let emptyArchive = string(forKey: "emptyArchive")
    static let emptySearchResult = string(forKey: "emptySearchResult")
    static let ended = string(forKey: "ended")
    static let episodes = string(forKey: "episodes")
    static let errorOccured = string(forKey: "errorOccured")
    static let filters = string(forKey: "filters")
    static let genres = string(forKey: "genres")
    static let goToSettings = string(forKey: "goToSettings")
    static let iCloudSync = string(forKey: "iCloudSync")
    static let inProduction = string(forKey: "inProduction")
    static let language = string(forKey: "language")
    static let languageChangeInstruction = string(forKey: "languageChangeInstruction")
    static let languageDescription = string(forKey: "languageDescription")
    static let languageRecommendation = string(forKey: "languageRecommendation")
    static let look = string(forKey: "look")
    static let lookYourHistory = string(forKey: "lookYourHistory")
    static let more = string(forKey: "more")
    static let newEpisodeTitleWithoutName = string(forKey: "newEpisodeTitleWithoutName")
    static let noDescription = string(forKey: "noDescription")
    static let notificationsAllowedText = string(forKey: "notificationsAllowedText")
    static let notificationsDeniedText = string(forKey: "notificationsDeniedText")
    static let notificationsDescription = string(forKey: "notificationsDescription")
    static let notificationsExplanationDescription = string(forKey: "notificationsExplanationDescription")
    static let notificationsNotDeterminedText = string(forKey: "notificationsNotDeterminedText")
    static let notificationsTimeDescription = string(forKey: "notificationsTimeDescription")
    static let notificationsTimeTitle = string(forKey: "notificationsTimeTitle")
    static let notificationsTitle = string(forKey: "notificationsTitle")
    static let noTrackingShows = string(forKey: "noTrackingShows")
    static let ongoing = string(forKey: "ongoing")
    static let open = string(forKey: "open")
    static let originalLanguage = string(forKey: "originalLanguage")
    static let ourTime = string(forKey: "ourTime")
    static let popular = string(forKey: "popular")
    static let releaseYear = string(forKey: "releaseYear")
    static let removeFromArchive = string(forKey: "removeFromArchive")
    static let removeFromFavourites = string(forKey: "removeFromFavourites")
    static let retry = string(forKey: "retry")
    static let search = string(forKey: "search")
    static let season = string(forKey: "season")
    static let settings = string(forKey: "settings")
    static let similar = string(forKey: "similar")
    static let snoozeForHour = string(forKey: "snoozeForHour")
    static let soon = string(forKey: "soon")
    static let sortBy = string(forKey: "sortBy")
    static let sortByNovelty = string(forKey: "sortByNovelty")
    static let sortByPopularity = string(forKey: "sortByPopularity")
    static let sortByRating = string(forKey: "sortByRating")
    static let status = string(forKey: "status")
    static let version = string(forKey: "version")
    static let yourShows = string(forKey: "yourShows")
    
    static func newEpisodeDescription(_ s1: String) -> String {
        string(forKey: "newEpisodeDescription", args: s1)
    }
    
    static func newEpisodeTitleWithName(_ s1: String) -> String {
        string(forKey: "newEpisodeTitleWithName", args: s1)
    }
    
    static func genrePlural(_ count: Int) -> String {
        let format = NSLocalizedString("genre_plural", tableName: "Localization", comment: "")
        return String.localizedStringWithFormat(format, count)
    }
    
    static func string(forKey key: String, args: String...) -> String {
        let format = Bundle.main.localizedString(
            forKey: key,
            value: nil,
            table: "Localization")
        return String(format: format, arguments: args)
    }
}
