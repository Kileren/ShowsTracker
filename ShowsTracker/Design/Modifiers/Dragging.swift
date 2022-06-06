//
//  Dragging.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import Foundation
import SwiftUI

struct Dragging: ViewModifier {
    
    @Binding var offset: CGFloat
    var onClose: () -> Void
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .gesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let height = value.translation.height
                let divider: CGFloat = height > 0 ? 2 : 5
                offset = height / divider
                if offset > 50 {
                    onClose()
                }
            }
            .onEnded { _ in
                withAnimation {
                    offset = 0
                }
            }
    }
}
