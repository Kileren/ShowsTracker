//
//  ImageProvidable.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import Foundation

protocol ImageProvidable {
    var posterPath: String? { get }
    var backdropPath: String? { get }
}

enum ImageProvidableType {
    case poster
    case backdrop
}
