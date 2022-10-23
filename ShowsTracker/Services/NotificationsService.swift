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
    private lazy var userActions: String = {
        let snoozeAction = UNNotificationAction(identifier: Self.snoozeIdentifier, title: Strings.snoozeForHour)
        let userActions = Self.userActionsIdentifier
        let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([category])
        return userActions
    }()
}

// MARK: - Public API

extension NotificationsService {
    
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
            content.title = Strings.newEpisodeTitleWithName(name)
        } else {
            content.title = Strings.newEpisodeTitleWithoutName
        }
        if let name = episode.name {
            content.body = Strings.newEpisodeDescription(name)
        }
        content.sound = .default
        content.badge = NSNumber(integerLiteral: await currentBadgeNumber + 1)
        content.categoryIdentifier = userActions
        
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
    
    func resheduleNotification(_ notification: UNNotification, for timeInterval: TimeInterval) async {
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(timeIntervalSinceNow: timeInterval))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let oldRequest = notification.request
        let request = UNNotificationRequest(identifier: oldRequest.identifier, content: oldRequest.content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            Logger.log(message: "Request with identifier - \(request) successfully rescheduled")
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

extension NotificationsService {
    static let snoozeIdentifier = "showsTracker.snoozeIdentifier"
    static let userActionsIdentifier = "showsTracker.userActions"
}
