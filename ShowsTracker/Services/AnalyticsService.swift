//
//  AnalyticsService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 19.11.2022.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsService {
    
    enum UserProperty {
        case numberOfLikedShows(value: Int)
        case numberOfArchivedShows(value: Int)
        case language(value: AppLanguage)
        case notificationStatus(value: String)
        case episodesTrackingEnabled(value: Bool)
        
        var rawValue: String {
            switch self {
            case .numberOfLikedShows: return "numberOfLikedShows"
            case .numberOfArchivedShows: return "numberOfArchivedShows"
            case .language: return "language"
            case .notificationStatus: return "notificationStatus"
            case .episodesTrackingEnabled: return "episodesTrackingEnabled"
            }
        }
        
        var value: String {
            switch self {
            case .numberOfLikedShows(let value): return String(value)
            case .numberOfArchivedShows(let value): return String(value)
            case .language(let value): return value.rawValue
            case .notificationStatus(let value): return value
            case .episodesTrackingEnabled(let value): return String(value)
            }
        }
    }
    
    func setUserID() {
        if let id = UIDevice().identifierForVendor?.description {
            Analytics.setUserID(id)
        }
    }
    
    func setUserProperty(property: UserProperty) {
        Logger.log(message: "🚀 Set user property with name - \(property.rawValue), parameter - \(property.value)", withImage: false)
        Analytics.setUserProperty(property.value, forName: property.rawValue)
    }
    
    func logAppLaunch() {
        logEvent("appLaunch", parameters: nil)
    }
    
    func logMainShowsTapLikedShow() {
        logEvent("mainShows_tapLikedShow", parameters: nil)
    }
    
    func logMainShowsTapPopularShow() {
        logEvent("mainShows_tapPopularShow", parameters: nil)
    }
    
    func logMainShowsTapAllShows() {
        logEvent("mainShows_tapAllShows", parameters: nil)
    }
    
    func logShowDetailsShown() {
        logEvent("showDetails_shown", parameters: nil)
    }
    
    func logShowDetailsTapDetails() {
        logEvent("showDetails_tapDetails", parameters: nil)
    }
    
    func logShowDetailsTapSimilar() {
        logEvent("showDetails_tapSimilar", parameters: nil)
    }
    
    func logShowDetailsTapEpisodes() {
        logEvent("showDetails_tapEpisodes", parameters: nil)
    }
    
    func logShowDetailsTapSimilarShow() {
        logEvent("showDetails_tapSimilarShow", parameters: nil)
    }
    
    func logShowDetailsTapNotify(on: Bool) {
        logEvent("showDetails_tapNotify", parameters: ["on": on.description])
    }
    
    func logShowsListShown() {
        logEvent("showsList_shown", parameters: nil)
    }
    
    func logShowsListTapUpcoming() {
        logEvent("showsList_tapUpcoming", parameters: nil)
    }
    
    func logShowsListTapPopular() {
        logEvent("showsList_tapPopular", parameters: nil)
    }
    
    func logShowsListStartSearch() {
        logEvent("showsList_startSearch", parameters: nil)
    }
    
    func logShowsListStartFilter() {
        logEvent("showsList_startFilter", parameters: nil)
    }
    
    func logNetworkErrorShown() {
        logEvent("networkError_shown", parameters: nil)
    }
    
    func logSettingsTapArchive() {
        logEvent("settings_tapArchive", parameters: nil)
    }
    
    func logAboutAppShown() {
        logEvent("aboutApp_shown", parameters: nil)
    }
    
    func logEvent(_ name: String, parameters: [String: Any]?) {
        Logger.log(message: "🚀 Log event with name - \(name), parameters - \(String(describing: parameters))", withImage: false)
        Analytics.logEvent(name, parameters: parameters)
    }
}
