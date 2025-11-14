import SwiftUI
import Combine

@MainActor
final class TimerManager: ObservableObject {
    @Published var timers: [PortTimer] = []

    private let persistence = PersistenceController.shared
    private let notificationManager = NotificationManager.shared

    // Notification settings from AppStorage
    @AppStorage("alert60") private var alert60 = true
    @AppStorage("alert30") private var alert30 = true
    @AppStorage("alert15") private var alert15 = true
    @AppStorage("alert5") private var alert5 = true

    init() {
        loadTimers()
    }

    // MARK: - Data Persistence

    /// Load all timers from Core Data
    func loadTimers() {
        timers = persistence.fetchAllTimers()
    }

    /// Add a new timer and persist it
    func addTimer(_ timer: PortTimer) {
        timers.append(timer)
        _ = persistence.createTimer(from: timer)

        // Schedule notifications for the new timer
        Task {
            await scheduleNotifications(for: timer)
        }
    }

    /// Remove a timer and delete from Core Data
    func removeTimer(_ id: UUID) {
        if let timer = timers.first(where: { $0.id == id }) {
            timers.removeAll { $0.id == id }
            persistence.deleteTimer(timer)

            // Cancel notifications for this timer
            Task {
                await notificationManager.cancelNotifications(for: id)
            }
        }
    }

    /// Update an existing timer and persist changes
    func updateTimer(_ updatedTimer: PortTimer) {
        if let index = timers.firstIndex(where: { $0.id == updatedTimer.id }) {
            timers[index] = updatedTimer
            persistence.updateTimer(updatedTimer)

            // Reschedule notifications for updated timer
            Task {
                await scheduleNotifications(for: updatedTimer)
            }
        }
    }

    /// Delete all timers (useful for testing/debugging)
    func deleteAllTimers() {
        timers.removeAll()
        persistence.deleteAllTimers()
        notificationManager.cancelAllNotifications()
    }

    // MARK: - Notifications

    /// Schedule notifications for a timer based on current settings
    private func scheduleNotifications(for timer: PortTimer) async {
        let settings = NotificationSettings(
            alert60: alert60,
            alert30: alert30,
            alert15: alert15,
            alert5: alert5
        )
        await notificationManager.scheduleNotifications(for: timer, settings: settings)
    }

    /// Reschedule all notifications (call when settings change)
    func rescheduleAllNotifications() async {
        for timer in timers {
            await scheduleNotifications(for: timer)
        }
    }
}
