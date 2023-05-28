//
//  UpdatesNotFoundView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 06.05.2023.
//

import SwiftUI

struct UpdatesNotFoundView: View {
    
    var lastCheck: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image("Icons/EmptyList")
                .renderingMode(.template)
                .resizable()
                .frame(width: 128, height: 128)
                .foregroundColor(.dynamic.text100)
            
            Text(Strings.noUpdates)
                .font(.medium20)
                .foregroundColor(.dynamic.text100)
            
            Text(Strings.lastCheck(lastCheck))
                .font(.regular13)
                .foregroundColor(.dynamic.text40)
        }
    }
}

struct UpdatesNotFoundView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesNotFoundView(lastCheck: "27/05/2023")
    }
}
