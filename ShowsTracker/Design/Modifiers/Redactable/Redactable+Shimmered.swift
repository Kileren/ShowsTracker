//
//  Redactable+Shimmered.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.05.2021.
//

import SwiftUI

struct Shimmered: ViewModifier {
    
    @State private var opacity: Double = 0.25
    
    private let maxOpacity: Double
    private let duration: TimeInterval
    
    init(minOpacity: Double = 0.25,
         maxOpacity: Double = 1,
         duration: TimeInterval = 0.8) {
        self.opacity = minOpacity
        self.maxOpacity = maxOpacity
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                let animation = Animation.easeInOut(duration: duration)
                let repeated = animation.repeatForever(autoreverses: true)
                withAnimation(repeated) {
                    self.opacity = maxOpacity
                }
            }
    }
}
