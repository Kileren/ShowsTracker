//
//  FavoritesShowsListModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 31.10.2022.
//

import SwiftUI

struct FavoritesShowsListModel {
    
    var shows: [Show] = []
    
    struct Show: Identifiable {
        var id: Int
        let image: Image
        let title: String
        let description: String
    }
}
