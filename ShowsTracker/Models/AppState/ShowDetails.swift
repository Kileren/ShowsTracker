//
//  ShowDetails.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 24.04.2022.
//

import SwiftUI

class ShowDetails: ObservableObject {
    
    @Published var id: Int = 0
    @Published var show: DetailedShow = .zero
    @Published var isLoaded: Bool = false
}
