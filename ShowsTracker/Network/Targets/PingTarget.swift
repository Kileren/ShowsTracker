//
//  PingTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 10.12.2022.
//

import Foundation
import Moya

enum PingTarget {
    case ping
}

extension PingTarget: TargetType {
    var baseURL: URL { URL(string: "https://api.themoviedb.org/3/")! }
    var path: String { "" }
    var method: Moya.Method { .get }
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    var task: Task {
        .requestPlain
    }
}
