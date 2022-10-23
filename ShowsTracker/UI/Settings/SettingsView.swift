//
//  SettingsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI
import Resolver

struct SettingsView: View {
    
    @InjectedObject private var viewModel: SettingsViewModel
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    @State private var cloudIsActive: Bool = true
    @State private var notificationsIsActive: Bool = false
    @State private var selectedTheme: ThemeToggleView.Theme = .auto
    
    var body: some View {
        NavigationView {
            VStack {
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
            .navigationTitle(Strings.settings)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background {
                Color.backgroundLight.ignoresSafeArea()
            }
            .onChange(of: notificationsIsActive) { newValue in
                if newValue {
                    viewModel.didTapTurnOnNotifications()
                }
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
    
    var cloudView: some View {
        SettingsCardView(
            image: Image("Icons/Settings/cloud"),
            title: Strings.iCloudSync,
            description: Strings.actualInfoOnAllDevices) {
                HStack {
                    Toggle(isOn: $cloudIsActive) { }
                        .labelsHidden()
                        .tint(.bay)
                        .frame(height: 20)
                }
            }
    }
    
    var archiveView: some View {
        NavigationLink {
            ArchiveShowsView()
        } label: {
            SettingsCardView(
                image: Image("Icons/Settings/archive"),
                title: Strings.archive,
                description: Strings.lookYourHistory) {
                    NavigationLink {
                        ArchiveShowsView()
                    } label: {
                        Text(Strings.look)
                            .font(.regular11)
                            .foregroundColor(.bay)
                            .frame(height: 24)
                    }
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
                        Text("Выключено")
                            .font(.regular10)
                            .foregroundColor(.text40)
                            .frame(height: 24)
                    }
                }
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
            image: Image("Icons/Settings/notificationOn"),
            title: Strings.aboutAppTitle,
            description: Strings.aboutAppDescription) {
                Button {
                    sheetNavigator.sheetDestination = .aboutApp
                } label: {
                    Text(Strings.open)
                        .font(.regular11)
                        .foregroundColor(.bay)
                        .frame(height: 24)
                }
            }
            .onTapGesture {
                sheetNavigator.sheetDestination = .aboutApp
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
