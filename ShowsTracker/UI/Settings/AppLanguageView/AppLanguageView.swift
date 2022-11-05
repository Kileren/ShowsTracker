//
//  AppLanguageView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 25.10.2022.
//

import SwiftUI

struct AppLanguageView: View {
    
    private var appLanguage: AppLanguage {
        AppLanguage(rawValue: AppSettings<AppLanguageKey>.value(for: AppLanguageKey.self))
    }
    
    var body: some View {
        VStack(spacing: 32) {
            warningBannerView
            VStack(spacing: 16) {
                descriptionTextView
                goToSettingsButton
            }
            Spacer()
        }
        .padding(.top, 24)
        .background {
            Color.dynamic.background.ignoresSafeArea()
        }
        .navigationTitle(Strings.language)
    }
    
    var warningBannerView: some View {
        HStack(spacing: 12) {
            if appLanguage == .en {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.greenLight)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 25, height: 23)
                    .foregroundColor(.orangeSoft)
            }
            
            Text(Strings.languageRecommendation)
                .font(.regular11)
                .foregroundColor(.dynamic.text40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.dynamic.infoView)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
        }
        .padding(.horizontal, 32)
    }
    
    var descriptionTextView: some View {
        Text(Strings.languageChangeInstruction)
            .font(.regular11)
            .foregroundColor(.dynamic.text40)
            .multilineTextAlignment(.center)
    }
    
    var goToSettingsButton: some View {
        STButton(title: Strings.goToSettings, style: .medium) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct AppLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        AppLanguageView()
    }
}
