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
}

protocol AppSettingKey {
    associatedtype Value
    
    static var defaultValue: Value { get }
    static var key: String { get }
}

struct NotificationsTimeKey: AppSettingKey {
    static var defaultValue: TimeInterval { 19 * 60 * 60 }
    static var key: String { "showsTracker.notificationsTimeKey" }
}
