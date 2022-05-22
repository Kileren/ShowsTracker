//
//  STSpacer.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 22.05.2022.
//

import SwiftUI

struct STSpacer: View {
    
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(width: 0, height: height)
            .foregroundColor(.clear)
    }
}

struct STSpacer_Previews: PreviewProvider {
    static var previews: some View {
        STSpacer(height: 100)
    }
}
