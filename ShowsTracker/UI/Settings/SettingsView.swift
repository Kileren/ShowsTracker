//
//  SettingsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI
import Resolver

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    @State private var cloudIsActive: Bool = true
    @State private var notificationsIsActive: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        themeView
                        languageView
                    }
                    HStack(spacing: 16) {
                        otherSettingsView
                        notificationView
                    }
                    HStack(spacing: 16) {
                        aboutAppView
                        aboutAppView.opacity(0)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                Spacer()
            }
            .navigationTitle(Strings.settings)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background {
                Color.dynamic.background.ignoresSafeArea()
            }
            .onChange(of: notificationsIsActive) { newValue in
                if newValue {
                    viewModel.didTapTurnOnNotifications()
                }
            }
            .onChange(of: viewModel.model.selectedTheme) { newValue in
                ThemeManager.shared.set(theme: newValue)
            }
            .sheet(isPresented: $sheetNavigator.showSheet,
                   content: sheetNavigator.sheetView)
            .onAppear {
                viewModel.viewAppeared()
            }
        }
    }
}

private extension SettingsView {
    var cardsView: some View {
        Text("")
    }
    
    var themeView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/theme"),
            title: Strings.appThemeTitle,
            description: Strings.appThemeDescription) {
                ThemeToggleView(selectedTheme: $viewModel.model.selectedTheme)
            }
    }
    
    var languageView: some View {
        NavigationLink {
            AppLanguageView()
        } label: {
            SettingsCardView(
                image: Image("Icons/Settings/global"),
                title: Strings.language,
                description: Strings.languageDescription) {
                    NavigationLink {
                        AppLanguageView()
                    } label: {
                        Text(viewModel.model.selectedLanguage)
                            .font(.regular11)
                            .foregroundColor(.dynamic.bay)
                            .frame(height: 24)
                    }
                }
        }
    }
    
    var notificationView: some View {
        NavigationLink {
            NotificationsView()
        } label: {
            SettingsCardView(
                image: Image("Icons/Settings/notificationOn"),
                title: Strings.notificationsTitle,
                description: Strings.notificationsDescription) {
                    switch viewModel.model.notificationsState {
                    case .on:
                        Image("checkmark").frame(height: 24)
                    case .off:
                        Toggle("", isOn: $notificationsIsActive)
                            .labelsHidden()
                            .tint(.bay)
                            .frame(height: 20)
                    case .empty:
                        Text(Strings.off)
                            .font(.regular10)
                            .foregroundColor(.dynamic.text40)
                            .frame(height: 24)
                    }
                }
        }
    }
    
    var otherSettingsView: some View {
        NavigationLink {
            OtherSettingsView()
        } label: {
            SettingsCardView(
                image: Image(systemName: "ellipsis.circle.fill"),
                title: Strings.otherSettings,
                description: Strings.additionalApplicationSettings) {
                    Text(Strings.open)
                        .font(.regular11)
                        .foregroundColor(.dynamic.bay)
                        .frame(height: 24)
                }
        }
    }
    
    var aboutAppView: some View {
        Button {
            sheetNavigator.sheetDestination = .aboutApp
        } label: {
            SettingsCardView(
                image: Image("Icons/Settings/notificationOn"),
                title: Strings.aboutAppTitle,
                description: Strings.aboutAppDescription) {
                    Button {
                        sheetNavigator.sheetDestination = .aboutApp
                    } label: {
                        Text(Strings.open)
                            .font(.regular11)
                            .foregroundColor(.dynamic.bay)
                            .frame(height: 24)
                    }
                }
        }
    }
}

// MARK: - Sheet Navigator

private class SheetNavigator: ObservableObject {
    
    @Published var showSheet = false
    var sheetDestination: SheetDestination = .none {
        didSet {
            showSheet = true
        }
    }
    
    enum SheetDestination {
        case none
        case aboutApp
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return AnyView(Text(""))
        case .aboutApp:
            return AnyView(AboutAppView())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
