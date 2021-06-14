//
//  DetailedShow.swift
//  ShowsTracker
//
//  Created by s.bogachev on 09.04.2021.
//

import SwiftUI

struct DetailedShow {
    let id = UUID()
    
    let imageData: Data?
//    let title: String
//    let overview: String?
//    let status: String
}

extension DetailedShow {
    var image: Image { imageData?.image ?? Image("") }
}

extension DetailedShow {
    static let zero = DetailedShow(imageData: nil)
}
