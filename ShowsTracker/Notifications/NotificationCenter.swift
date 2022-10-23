//
//  NotificationCenter.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import Foundation
import UserNotifications
import Resolver

final class NotificationCenterDelegate: NSObject {
    
    @Injected private var notificationService: NotificationsService
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationCenterDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case NotificationsService.snoozeIdentifier:
            Task {
                await notificationService.resheduleNotification(response.notification, for: 3600)
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        default:
            completionHandler()
        }
    }
}
