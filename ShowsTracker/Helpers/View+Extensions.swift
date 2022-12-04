//
//  View+Extensions.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 04.12.2022.
//

import SwiftUI

extension View {
    func embedInNavigationView() -> some View {
        NavigationView {
            self
        }
    }
}
