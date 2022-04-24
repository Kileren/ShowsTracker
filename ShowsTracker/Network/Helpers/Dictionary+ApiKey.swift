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
        return dict
    }
}
