//
//  SettingsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation
import Resolver

final class SettingsViewModel: ObservableObject {
    
    @Injected private var notificationsService: NotificationsService
    
    @AppSettings<AppLanguageKey> private var appLanguageValue
    @AppSettings<AppThemeKey> private var appThemeValue
    
    @Published var model = SettingsModel()
    
    func viewAppeared() {
        Task {
            await getNotificationStatusAndChangeModel()
        }
        getLanguageAndChangeModel()
        getAppThemeAndChangeModel()
    }
}

// MARK: - Public API

extension SettingsViewModel {
    func didTapTurnOnNotifications() {
        Task {
            await notificationsService.requestAuthorization()
            await getNotificationStatusAndChangeModel()
        }
    }
}

// MARK: - Helpers

private extension SettingsViewModel {
    
    @MainActor
    func changeModel(completion: (inout SettingsModel) -> Void) {
        completion(&model)
    }
    
    func getNotificationStatusAndChangeModel() async {
        switch await notificationsService.getStatus() {
        case .authorized:
            await changeModel { $0.notificationsState = .on }
        case .notDetermined:
            await changeModel { $0.notificationsState = .off }
        default:
            await changeModel { $0.notificationsState = .empty }
        }
    }
    
    func getLanguageAndChangeModel() {
        switch AppLanguage(rawValue: appLanguageValue) {
        case .en: model.selectedLanguage = "English"
        case .ru: model.selectedLanguage = "Русский"
        }
    }
    
    func getAppThemeAndChangeModel() {
        model.selectedTheme = AppTheme(rawValue: appThemeValue)
    }
}
