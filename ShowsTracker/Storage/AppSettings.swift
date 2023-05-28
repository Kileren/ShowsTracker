//
//  AppSettings.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation

@propertyWrapper
struct AppSettings<Key: AppSettingKey> {
    
    public var wrappedValue: Key.Value {
        get {
            (UserDefaults.standard.value(forKey: Key.key) as? Key.Value) ?? Key.defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.key)
        }
    }
    
    public static func value<T: AppSettingKey>(for key: T.Type) -> Key.Value {
        (UserDefaults.standard.value(forKey: Key.key) as? Key.Value) ?? Key.defaultValue
    }
    
    public static func setValue<T: AppSettingKey>(value: T.Value, for key: T.Type) {
        UserDefaults.standard.set(value, forKey: T.key)
    }
}

protocol AppSettingKey {
    associatedtype Value
    
    static var defaultValue: Value { get }
    static var key: String { get }
}

/// The time at which notifications will be sent
struct NotificationsTimeKey: AppSettingKey {
    static var defaultValue: TimeInterval { 19 * 60 * 60 }
    static var key: String { "showsTracker.notificationsTimeKey" }
}

/// Selected app language
struct AppLanguageKey: AppSettingKey {
    static var defaultValue: String { AppLanguage.en.rawValue }
    static var key: String { "showsTracker.selectedAppLanguage" }
}

/// Selected app theme
struct AppThemeKey: AppSettingKey {
    static var defaultValue: String { AppTheme.unspecified.rawValue }
    static var key: String { "showsTracker.selectedAppTheme" }
}

/// Boolean indicating whether episodes tracking enabled or not
struct EpisodesTrackingKey: AppSettingKey {
    static var defaultValue: Bool { true }
    static var key: String { "showsTracker.episodesTrackingKey" }
}

/// The date when user checked his shows updates last time
struct LastUpdatesCheckKey: AppSettingKey {
    static var defaultValue: Date? { nil }
    static var key: String { "showsTracker.lastUpdatesCheckKey" }
}
