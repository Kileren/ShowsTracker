//
//  AboutAppView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 12.10.2022.
//

import SwiftUI
import Resolver
import StoreKit

struct AboutAppView: View {
    
    @Injected private var analyticsService: AnalyticsService
    
    @StateObject private var viewModel = AboutAppViewModel()
    
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        ZStack {
            Color.dynamic.backgroundEl1.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                Image("Icon")
                Spacer()
                rateView
                Text("\(Strings.version) \(version ?? "")")
                    .foregroundColor(.dynamic.text60)
                    .font(.regular17)
                    .padding(.bottom, 16)
            }
            .navigationTitle(Strings.aboutAppTitle)
            .onAppear {
                analyticsService.logAboutAppShown()
            }
        }
    }
}

private extension AboutAppView {
    var rateView: some View {
        Button {
            viewModel.didTapRateButton()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 56)
                    .foregroundColor(.dynamic.backgroundEl2)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellowSoft)
                    Spacer()
                }
                .padding(.leading, 16)
                
                Text(Strings.rateTheApp)
                    .font(.regular17)
                    .foregroundColor(.dynamic.text100)
            }
            .padding(.horizontal, 24)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
