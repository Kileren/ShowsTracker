//
//  AboutAppView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 12.10.2022.
//

import SwiftUI

struct AboutAppView: View {
    
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        ZStack {
            Color.backgroundLight.ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("Icon")
                Spacer()
                Text("\(Strings.version) \(version ?? "")")
                    .foregroundColor(.text100)
                    .font(.medium20)
                    .padding(.bottom, 16)
            }
            .navigationTitle(Strings.aboutAppTitle)
        }
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
