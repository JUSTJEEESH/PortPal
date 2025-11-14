//
//  NotificationManager.swift
//  PortPal
//
//  Manages push notifications for departure countdowns
//

import Foundation
import UserNotifications
import UIKit

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Request notification permissions from the user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Schedule Notifications

    /// Schedule all notifications for a given timer
    func scheduleNotifications(for timer: PortTimer, settings: NotificationSettings) async {
        // Request authorization if needed
        if authorizationStatus == .notDetermined {
            _ = await requestAuthorization()
        }

        guard authorizationStatus == .authorized else {
            print("Notifications not authorized")
            return
        }

        // Cancel existing notifications for this timer
        await cancelNotifications(for: timer.id)

        // Schedule enabled notifications
        if settings.alert60 {
            await scheduleNotification(
                for: timer,
                minutesBefore: 60,
                priority: .timeSensitive,
                title: "Departure in 1 Hour",
                body: "Your ship departs from \(timer.port) in 1 hour. Start heading back soon!"
            )
        }

        if settings.alert30 {
            await scheduleNotification(
                for: timer,
                minutesBefore: 30,
                priority: .timeSensitive,
                title: "Departure in 30 Minutes",
                body: "Your ship departs from \(timer.port) in 30 minutes. Time to head back!"
            )
        }

        if settings.alert15 {
            await scheduleNotification(
                for: timer,
                minutesBefore: 15,
                priority: .critical,
                title: "⚠️ Departure in 15 Minutes!",
                body: "Your ship departs from \(timer.port) in 15 minutes. Return to the ship NOW!"
            )
        }

        if settings.alert5 {
            await scheduleNotification(
                for: timer,
                minutesBefore: 5,
                priority: .critical,
                title: "🚨 URGENT: Departing in 5 Minutes!",
                body: "Your ship is departing from \(timer.port) in 5 minutes! GET BACK NOW!"
            )
        }
    }

    /// Schedule a single notification
    private func scheduleNotification(
        for timer: PortTimer,
        minutesBefore: Int,
        priority: NotificationPriority,
        title: String,
        body: String
    ) async {
        let notificationTime = timer.departure.addingTimeInterval(-Double(minutesBefore * 60))

        // Don't schedule if the time has already passed
        guard notificationTime > Date() else {
            print("Skipping past notification: \(title)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = priority == .critical ? .defaultCritical : .default
        content.categoryIdentifier = "DEPARTURE_ALERT"
        content.userInfo = [
            "timerId": timer.id.uuidString,
            "port": timer.port,
            "ship": timer.ship,
            "minutesBefore": minutesBefore
        ]

        // Set interruption level (iOS 15+)
        if priority == .critical {
            content.interruptionLevel = .critical
        } else if priority == .timeSensitive {
            content.interruptionLevel = .timeSensitive
        }

        // Badge number
        content.badge = NSNumber(value: minutesBefore)

        // Create trigger
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationTime
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create request
        let identifier = "\(timer.id.uuidString)-\(minutesBefore)min"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled notification: \(title) at \(notificationTime)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }

    // MARK: - Cancel Notifications

    /// Cancel all notifications for a specific timer
    func cancelNotifications(for timerId: UUID) async {
        let identifiers = [
            "\(timerId.uuidString)-60min",
            "\(timerId.uuidString)-30min",
            "\(timerId.uuidString)-15min",
            "\(timerId.uuidString)-5min"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled notifications for timer: \(timerId)")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all notifications")
    }

    /// Get list of pending notifications (for debugging)
    func listPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - Notification Actions

    /// Register notification categories and actions
    func registerNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_TIMER",
            title: "View Timer",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind in 5 min",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "DEPARTURE_ALERT",
            actions: [viewAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

// MARK: - Supporting Types

enum NotificationPriority {
    case normal
    case timeSensitive
    case critical
}

struct NotificationSettings {
    var alert60: Bool
    var alert30: Bool
    var alert15: Bool
    var alert5: Bool

    init(alert60: Bool = true, alert30: Bool = true, alert15: Bool = true, alert5: Bool = true) {
        self.alert60 = alert60
        self.alert30 = alert30
        self.alert15 = alert15
        self.alert5 = alert5
    }
}
