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
    
    @Published var model = SettingsModel()
    
    func viewAppeared() {
        Task {
            await getNotificationStatusAndChangeModelIfNeeded()
        }
    }
}

// MARK: - Public API

extension SettingsViewModel {
    func didTapTurnOnNotifications() {
        Task {
            await notificationsService.requestAuthorization()
            await getNotificationStatusAndChangeModelIfNeeded()
        }
    }
}

// MARK: - Helpers

private extension SettingsViewModel {
    
    @MainActor
    func changeModel(completion: (inout SettingsModel) -> Void) {
        completion(&model)
    }
    
    func getNotificationStatusAndChangeModelIfNeeded() async {
        switch await notificationsService.getStatus() {
        case .authorized:
            await changeModel { $0.notificationsState = .on }
        case .notDetermined:
            await changeModel { $0.notificationsState = .off }
        default:
            await changeModel { $0.notificationsState = .empty }
        }
    }
}
