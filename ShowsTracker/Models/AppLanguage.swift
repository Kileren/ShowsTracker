//
//  AppLanguage.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.10.2022.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case en
    case ru
    
    init(rawValue: String) {
        switch rawValue {
        case AppLanguage.en.rawValue: self = .en
        case AppLanguage.ru.rawValue: self = .ru
        default: self = .en
        }
    }
}
