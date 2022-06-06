//
//  View+DisableDragging.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.05.2022.
//

import SwiftUI

extension View {
    func disableDragging() -> some View {
        self.gesture(DragGesture())
    }
}
