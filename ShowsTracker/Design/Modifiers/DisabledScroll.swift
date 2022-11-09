//
//  DisabledScroll.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 08.11.2022.
//

import SwiftUI

struct DisabledScroll: ViewModifier {
    let flag: Bool
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.scrollDisabled(flag)
        } else {
            content
        }
    }
}
