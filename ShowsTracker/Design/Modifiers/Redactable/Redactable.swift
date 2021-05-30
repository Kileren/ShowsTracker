//
//  Redactable.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.05.2021.
//

import SwiftUI

enum RedactionReason {
    case shimmer
}

struct Redactable: ViewModifier {
    let reason: RedactionReason?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch reason {
        case .shimmer:
            content.modifier(Shimmered())
        case nil:
            content
        }
    }
}

extension View {
    func redacted(reason: RedactionReason?) -> some View {
        modifier(Redactable(reason: reason))
    }
}
