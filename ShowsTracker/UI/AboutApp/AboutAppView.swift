//
//  AboutAppView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 12.10.2022.
//

import SwiftUI
import Resolver

struct AboutAppView: View {
    
    @Injected private var analyticsService: AnalyticsService
    
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        ZStack {
            Color.dynamic.backgroundEl1.ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("Icon")
                Spacer()
                Text("\(Strings.version) \(version ?? "")")
                    .foregroundColor(.dynamic.text100)
                    .font(.medium20)
                    .padding(.bottom, 16)
            }
            .navigationTitle(Strings.aboutAppTitle)
            .onAppear {
                analyticsService.logAboutAppShown()
            }
        }
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
