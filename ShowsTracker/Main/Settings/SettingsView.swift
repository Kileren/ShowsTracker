//
//  SettingsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var cloudIsActive: Bool = true
    @State private var selectedTheme: ThemeToggleView.Theme = .auto
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                titleView
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        cloudView
                        archiveView
                    }
                    HStack(spacing: 16) {
                        regionView
                        notificationView
                    }
                    HStack(spacing: 16) {
                        themeView
                        aboutAppView
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background(Color.backgroundLight)
    }
}

private extension SettingsView {
    var titleView: some View {
        HStack {
            Text(Strings.settings)
                .font(.medium32Rounded)
                .foregroundColor(.text100)
            Spacer()
        }
    }
    
    var cardsView: some View {
        Text("")
    }
    
    var cloudView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/cloud"),
            title: Strings.iCloudSync,
            description: Strings.actualInfoOnAllDevices) {
                HStack {
                    Toggle(isOn: $cloudIsActive) { }
                        .labelsHidden()
                        .tint(.bay)
                }
            }
    }
    
    var archiveView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/archive"),
            title: Strings.archive,
            description: Strings.lookYourHistory) {
                Button {
                    print("Tap archive view")
                } label: {
                    Text(Strings.look)
                        .font(.regular11)
                        .foregroundColor(.bay)
                        .frame(height: 24)
                }
            }
    }
    
    var regionView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/global"),
            title: Strings.region,
            description: Strings.regionDescription) {
                Button {
                    print("Tap region view")
                } label: {
                    Text("Российская Федерация")
                        .font(.regular11)
                        .foregroundColor(.bay)
                        .frame(height: 24)
                }
            }
    }
    
    var notificationView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/notification"),
            title: Strings.notificationsTitle,
            description: Strings.notificationsDescription) {
                Image("checkmark")
                    .frame(height: 24)
            }
    }
    
    var themeView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/theme"),
            title: Strings.appThemeTitle,
            description: Strings.appThemeDescription) {
                ThemeToggleView(selectedTheme: $selectedTheme)
            }
    }
    
    var aboutAppView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/notification"),
            title: Strings.aboutAppTitle,
            description: Strings.aboutAppDescription) {
                Button {
                    print("Tap about app view")
                } label: {
                    Text(Strings.open)
                        .font(.regular11)
                        .foregroundColor(.bay)
                        .frame(height: 24)
                }
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
