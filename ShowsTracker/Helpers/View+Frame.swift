//
//  View+Frame.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 08.09.2022.
//

import SwiftUI

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }
}
