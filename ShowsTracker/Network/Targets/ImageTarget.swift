//
//  ImageTarget.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.04.2022.
//

import Foundation
import Moya

enum ImageTarget {
    case image(path: String, width: Int)
}

extension ImageTarget: TargetType {
    var baseURL: URL { URL(string: "https://image.tmdb.org/t/p/")! }
    
    var path: String {
        switch self {
        case .image(let path, let width):
            return "w\(width)\(path)"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
}
