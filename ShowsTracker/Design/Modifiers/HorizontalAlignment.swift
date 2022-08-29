//
//  HorizontalAlignment.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.08.2022.
//

import Foundation
import SwiftUI

struct HorizontalAlignment: ViewModifier {
    
    private let alignment: Alignment
    
    init(alignment: Alignment = .center) {
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            if alignment == .leading || alignment == .center {
                Spacer()
            }
            content
            if alignment == .trailing || alignment == .center {
                Spacer()
            }
        }
    }
}
