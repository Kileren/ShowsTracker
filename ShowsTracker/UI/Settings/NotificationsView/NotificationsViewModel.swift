//
//  NotificationsViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import Foundation
import Resolver
import UIKit

final class NotificationsViewModel: ObservableObject {
    
    @Injected private var notificationService: NotificationsService
    
    @AppSettings<NotificationsTimeKey> private var notificationsTime: TimeInterval
    
    @Published var model = NotificationsModel()
    
    func viewAppeared() {
        model.selectedTime = Calendar.current.date(from: DateComponents(second: Int(notificationsTime))) ?? Date(timeIntervalSinceReferenceDate: 0)
        
        Task {
            await getNotificationStatusAndChangeModelIfNeeded()
        }
    }
}

// MARK: - Public API

extension NotificationsViewModel {
    func notificationTimeDidChange(_ value: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: value)
        if let hour = components.hour, let minute = components.minute {
            notificationsTime = TimeInterval(hour * 60 * 60 + minute * 60)
        }
    }
    
    func didTapAllowNotification() {
        Task {
            await notificationService.requestAuthorization()
            await getNotificationStatusAndChangeModelIfNeeded()
        }
    }
    
    func didTapGoToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Private API

private extension NotificationsViewModel {
    
    func getNotificationStatusAndChangeModelIfNeeded() async {
        let status = await notificationService.getStatus()
        switch status {
        case .notDetermined:
            await changeModel { $0.state = .notDetermined }
        case .denied:
            await changeModel { $0.state = .denied }
        case .authorized:
            await changeModel { $0.state = .allowed }
        case .provisional:
            // Provisional notifications not in use
            await changeModel { $0.state = .allowed }
        case .ephemeral:
            // App Clips only
            await changeModel { $0.state = .allowed }
        @unknown default:
            Logger.log(warning: "Unknown notification")
            await changeModel { $0.state = .allowed }
        }
    }
    
    @MainActor
    func changeModel(completion: (inout NotificationsModel) -> Void) {
        completion(&model)
    }
}
