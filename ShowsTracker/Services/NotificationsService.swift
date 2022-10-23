//
//  NotificationsService.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 16.10.2022.
//

import UIKit
import UserNotifications

final class NotificationsService {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @AppSettings<NotificationsTimeKey> private var notificationTime
    
    private lazy var options: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    @discardableResult
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            notificationCenter.requestAuthorization(options: options) { isSuccess, error in
                Logger.log(message: "Notification request authorization result - \(isSuccess)")
                if let error = error {
                    Logger.log(error: error)
                }
                continuation.resume(returning: isSuccess)
            }
        }
    }
    
    func getStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continiation in
            notificationCenter.getNotificationSettings { setting in
                continiation.resume(returning: setting.authorizationStatus)
            }
        }
    }
    
    func scheduleNotification(title: String, message: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.badge = NSNumber(integerLiteral: await currentBadgeNumber + 1)
        
        let date = Date(timeIntervalSinceNow: 5)
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        // Should be unique
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            Logger.log(message: "Request with identifier - \(request) successfully added")
        } catch {
            Logger.log(error: error)
        }
    }
}

// MARK: - Public API

extension NotificationsService {
    
    func scheduleNotification(for seasonDetails: SeasonDetails, seasonNumber: Int, plainShow: PlainShow) async {
        let episodes = seasonDetails.episodes?.compactMap { $0 } ?? []
        for episode in episodes {
            await scheduleNotification(for: episode, seasonNumber: seasonNumber, showID: plainShow.id, showName: plainShow.name)
        }
    }
    
    func scheduleNotification(for episode: SeasonDetails.Episode, seasonNumber: Int, showID: Int, showName: String?) async {
        guard let airDate = episode.airDate,
              let date = STDateFormatter.date(from: airDate, format: .airDate) else { return }
        
        let content = UNMutableNotificationContent()
        if let name = showName {
            content.title = "\(name) - новая серия!"
        } else {
            content.title = "Вышла новая серия!"
        }
        if let name = episode.name {
            content.body = "Серия \"\(name)\" выходит сегодня, не забудьте посмотреть."
        }
        content.sound = .default
        content.badge = NSNumber(integerLiteral: await currentBadgeNumber + 1)
        
        let additionalTimeInterval: TimeInterval = notificationTime
        let dateWithOffset = date.addingTimeInterval(additionalTimeInterval)
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateWithOffset)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        // IDENTIFIER FORMAT
        // <SHOW ID>.<SEASON NUMBER>.<EPISODE NUMBER>
        let identifier = "\(showID).\(seasonNumber).\(episode.episodeNumber ?? 0)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            Logger.log(message: "Request with identifier - \(request) successfully added")
        } catch {
            Logger.log(error: error)
        }
    }
    
    func getPendingRequestsIDs() async -> [String] {
        await notificationCenter.pendingNotificationRequests().map { $0.identifier }
    }
    
    func removePendingNotifications(showID: Int, seasonNumber: Int) async {
        let idsToRemove = await getPendingRequestsIDs().filter { $0.starts(with: "\(showID).\(seasonNumber)") }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
    }
}

// MARK: - Helpers

private extension NotificationsService {
    @MainActor
    private var currentBadgeNumber: Int {
        UIApplication.shared.applicationIconBadgeNumber
    }
}
