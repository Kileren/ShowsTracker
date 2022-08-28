//
//  STSpacer.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 22.05.2022.
//

import SwiftUI

struct STSpacer: View {
    
    let height: CGFloat
    let width: CGFloat?
    let color: Color
    
    init(height: CGFloat = 0, width: CGFloat? = 0, color: Color = .clear) {
        self.height = height
        self.width = width
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .frame(width: width, height: height)
            .foregroundColor(color)
    }
}

struct STSpacer_Previews: PreviewProvider {
    static var previews: some View {
        STSpacer(height: 100)
    }
}
