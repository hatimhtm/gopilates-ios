import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let trialReminderID = "gopilates.trial_end_reminder"

    private init() {}

    /// Returns true if the user has already authorized notifications, or grants permission now.
    func requestPermissionIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    /// Schedules a single local notification for ~1 day before the 3-day free trial ends.
    /// Fires at 10:00 local time on (today + 2 days).
    func scheduleTrialEndReminder() async {
        let granted = await requestPermissionIfNeeded()
        guard granted else { return }

        guard let fireDay = Calendar.current.date(byAdding: .day, value: 2, to: Date()) else { return }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDay)
        components.hour = 10
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Votre essai gratuit prend fin demain"
        content.body = "Profitez de votre dernière journée d'accès Premium GoPilates. Annulez à tout moment dans Réglages."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: trialReminderID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [trialReminderID])
        try? await center.add(request)
    }

    func cancelTrialEndReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [trialReminderID])
    }
}
