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
    
    static func string(forKey key: String) -> String {
        Bundle.main.localizedString(
            forKey: key,
            value: nil,
            table: "Localization")
    }
}
