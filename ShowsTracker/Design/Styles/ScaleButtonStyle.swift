//
//  ScaleButtonStyle.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.08.2022.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    @State private var isPressed: Bool = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(isPressed ? 0.95 : 1)
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.interactiveSpring()) {
                    self.isPressed = newValue
                }
            }
    }
}
