//
//  Dictionary+ApiKey.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var withApiKey: [String: Any] {
        var dict = self
        dict["api_key"] = ""
        dict["language"] = languageCode
        return dict
    }
    
    private var languageCode: String {
        switch AppSettings<AppLanguageKey>.value(for: AppLanguageKey.self) {
        case AppLanguage.ru.rawValue:
            return "ru-RU"
        case AppLanguage.en.rawValue:
            return "en-US"
        default:
            return "en-US"
        }
    }
}
