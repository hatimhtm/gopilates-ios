import Foundation
import SwiftUI

// MARK: - User Profile

class UserProfile: ObservableObject {
    @AppStorage("userName") var name: String = "Utilisatrice"
    @AppStorage("currentStreakDays") var currentStreak: Int = 0
    @AppStorage("totalSessionsCompleted") var totalSessions: Int = 0
    @AppStorage("totalMinutesExercised") var totalMinutes: Int = 0
    @AppStorage("challengeDayCompleted") var challengeDayCompleted: Int = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // Onboarding data stored
    @AppStorage("userHeightCm") var heightCm: Int = 165
    @AppStorage("userCurrentWeight") var currentWeightKg: Double = 65.0
    @AppStorage("userTargetWeight") var targetWeightKg: Double = 60.0
    @AppStorage("userAge") var age: Int = 30
    @AppStorage("userFitnessLevel") var fitnessLevel: String = "Débutante"

    // Settings
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("voiceCoachingEnabled") var voiceCoachingEnabled: Bool = true

    // Last session date for streak calculation
    @AppStorage("lastSessionDate") var lastSessionDateString: String = ""

    // Tracks the exact calendar date the challenge was started
    @AppStorage("challengeStartDate") var challengeStartDateString: String = ""

    // Tracks the last calendar date a challenge day was completed
    @AppStorage("lastChallengeCompletionDate") var lastChallengeCompletionDate: String = ""

    // Completed dates for calendar tracking (JSON encoded array of "yyyy-MM-dd" strings)
    @AppStorage("completedDatesJSON") var completedDatesJSON: String = "[]"

    // Injuries stored from onboarding (JSON encoded Set<String>)
    @AppStorage("userInjuriesJSON") var injuriesJSON: String = "[]"

    // Today's completed workout IDs (resets at midnight via logic below)
    @AppStorage("todayCompletedWorkoutDate") var todayCompletedWorkoutDate: String = ""
    @AppStorage("todayCompletedWorkoutIDsJSON") var todayCompletedWorkoutIDsJSON: String = "[]"
    @AppStorage("allCompletedExerciseIDsJSON") var allCompletedExerciseIDsJSON: String = "[]"
    
    // Daily "Seance Douce" completion tracking
    @AppStorage("todaySeanceDouceDate") var todaySeanceDouceDate: String = ""

    // MARK: - Computed Properties
    
    var hasCompletedTodaySeanceDouce: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return todaySeanceDouceDate == formatter.string(from: Date())
    }

    func markSeanceDouceCompletedToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaySeanceDouceDate = formatter.string(from: Date())
    }

    var daysSinceChallengeStart: Int {
        guard !challengeStartDateString.isEmpty else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let startDate = formatter.date(from: challengeStartDateString) else { return 0 }
        
        let cal = Calendar.current
        let startOfDayStart = cal.startOfDay(for: startDate)
        let startOfDayToday = cal.startOfDay(for: Date())
        
        return max(0, cal.dateComponents([.day], from: startOfDayStart, to: startOfDayToday).day ?? 0)
    }

    var canUnlockNextChallengeDay: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return lastChallengeCompletionDate != today
    }

    var bmi: Double {
        let heightM = Double(heightCm) / 100.0
        guard heightM > 0 else { return 0 }
        return currentWeightKg / pow(heightM, 2)
    }

    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Insuffisance pondérale"
        case 18.5..<25: return "Poids normal"
        case 25..<30: return "Surpoids"
        default: return "Obésité"
        }
    }

    var weightToLose: Double {
        max(0, currentWeightKg - targetWeightKg)
    }

    var progressPercent: Double {
        guard weightToLose > 0 else { return 1.0 }
        let estimatedLossPerSession = 0.05
        let estimatedLoss = Double(totalSessions) * estimatedLossPerSession
        return min(1.0, estimatedLoss / weightToLose)
    }

    var challengeProgressPercent: Double {
        Double(challengeDayCompleted) / 30.0
    }

    // MARK: - Injury Filtering

    var injuries: Set<String> {
        get {
            guard let data = injuriesJSON.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return Set(arr)
        }
        set {
            if let data = try? JSONEncoder().encode(Array(newValue)),
               let str = String(data: data, encoding: .utf8) {
                injuriesJSON = str
            }
        }
    }

    /// Returns true if an exercise should be excluded due to user's injuries.
    func isExerciseSafe(_ exercise: PilatesExercise) -> Bool {
        guard !injuries.isEmpty && !injuries.contains("Aucune blessure") else { return true }
        let muscles = exercise.targetMuscles.joined(separator: " ").lowercased()
        let name = exercise.name.lowercased()
        let precaution = exercise.precautions?.lowercased() ?? ""

        for injury in injuries {
            switch injury {
            case "Genou":
                if muscles.contains("quadriceps") || muscles.contains("genou") ||
                   name.contains("squat") || name.contains("chaise") { return false }
            case "Bas du dos":
                if precaution.contains("lombaire") || precaution.contains("dos") ||
                   muscles.contains("lombaires") && exercise.difficulty == .advanced { return false }
            case "Épaule":
                if muscles.contains("deltoïdes") || muscles.contains("pectoraux") ||
                   muscles.contains("triceps") || name.contains("pompe") { return false }
            case "Cheville":
                if name.contains("mollet") || muscles.contains("mollets") ||
                   muscles.contains("cheville") { return false }
            case "Cou":
                if precaution.contains("cervikal") || precaution.contains("cervical") ||
                   precaution.contains("nuque") { return false }
            case "Hanche":
                if muscles.contains("psoas") && exercise.difficulty == .advanced { return false }
            default: break
            }
        }
        return true
    }

    // MARK: - Today's Completed Workouts (greys out until midnight)

    var todayCompletedWorkoutIDs: Set<String> {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let today = formatter.string(from: Date())
            // Reset if it's a new day
            if todayCompletedWorkoutDate != today { return [] }
            guard let data = todayCompletedWorkoutIDsJSON.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return Set(arr)
        }
    }

    var allCompletedExerciseIDs: Set<String> {
        get {
            guard let data = allCompletedExerciseIDsJSON.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return Set(arr)
        }
    }

    func markWorkoutCompletedToday(_ exerciseID: UUID) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        // Reset if new day
        var ids: Set<String>
        if todayCompletedWorkoutDate != today {
            todayCompletedWorkoutDate = today
            ids = [exerciseID.uuidString]
        } else {
            ids = todayCompletedWorkoutIDs
            ids.insert(exerciseID.uuidString)
        }
        
        if let data = try? JSONEncoder().encode(Array(ids)),
           let str = String(data: data, encoding: .utf8) {
            todayCompletedWorkoutIDsJSON = str
        }

        // Add to all-time completed list
        var allIds = allCompletedExerciseIDs
        if !allIds.contains(exerciseID.uuidString) {
            allIds.insert(exerciseID.uuidString)
            if let allData = try? JSONEncoder().encode(Array(allIds)),
               let allStr = String(data: allData, encoding: .utf8) {
                allCompletedExerciseIDsJSON = allStr
            }
        }
    }

    @AppStorage("previouslyEarnedBadgesJSON") var previouslyEarnedBadgesJSON: String = "[]"
    @Published var newlyUnlockedBadge: Badge? = nil

    var previouslyEarnedBadges: [String] {
        guard let data = previouslyEarnedBadgesJSON.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return arr
    }

    var earnedBadges: [Badge] {
        var badges: [Badge] = []
        if totalSessions >= 1  { badges.append(.firstSession) }
        if currentStreak >= 7  { badges.append(.weekStreak) }
        if totalMinutes >= 100 { badges.append(.hundredMinutes) }
        if challengeDayCompleted >= 30 { badges.append(.challengeComplete) }
        return badges
    }

    // MARK: - Session Tracking

    func completeSession(durationMinutes: Int) {
        objectWillChange.send()
        
        let oldBadges = earnedBadges
        totalSessions += 1
        totalMinutes += durationMinutes
        markDateCompleted()
        updateStreak()
        
        // Check for newly unlocked badges
        let newBadges = earnedBadges
        if let newBadge = newBadges.first(where: { !oldBadges.contains($0) && !previouslyEarnedBadges.contains($0.rawValue) }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.newlyUnlockedBadge = newBadge
                
                var saved = self.previouslyEarnedBadges
                saved.append(newBadge.rawValue)
                if let data = try? JSONEncoder().encode(saved), let str = String(data: data, encoding: .utf8) {
                    self.previouslyEarnedBadgesJSON = str
                }
            }
        }
    }

    func completeChallengeDay(_ day: Int) {
        objectWillChange.send()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        if challengeStartDateString.isEmpty {
            challengeStartDateString = todayStr
        }
        
        if day > challengeDayCompleted {
            challengeDayCompleted = day
        }

        lastChallengeCompletionDate = todayStr
    }

    private func updateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        if lastSessionDateString.isEmpty {
            currentStreak = 1
        } else if let lastDate = formatter.date(from: lastSessionDateString) {
            let daysDiff = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysDiff == 1 {
                currentStreak += 1
            } else if daysDiff > 1 {
                currentStreak = 1
            }
        }
        lastSessionDateString = today
    }

    // MARK: - Date Tracking

    var completedDates: [String] {
        guard let data = completedDatesJSON.data(using: .utf8),
              let dates = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return dates
    }

    func markDateCompleted() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        var dates = completedDates
        if !dates.contains(today) {
            dates.append(today)
            if let data = try? JSONEncoder().encode(dates),
               let str = String(data: data, encoding: .utf8) {
                completedDatesJSON = str
            }
        }
    }

    func isDateCompleted(_ date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return completedDates.contains(formatter.string(from: date))
    }

    // MARK: - Streak Analytics

    var longestStreak: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let sortedDates = completedDates.compactMap { formatter.date(from: $0) }.sorted()
        var best = 0, current = 0
        var prev: Date? = nil
        for date in sortedDates {
            if let p = prev, Calendar.current.dateComponents([.day], from: p, to: date).day == 1 {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
            prev = date
        }
        return best
    }

    var workoutsThisMonth: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let now = Date()
        return completedDates.compactMap { formatter.date(from: $0) }.filter {
            cal.isDate($0, equalTo: now, toGranularity: .month)
        }.count
    }

    var workoutsThisYear: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let now = Date()
        return completedDates.compactMap { formatter.date(from: $0) }.filter {
            cal.isDate($0, equalTo: now, toGranularity: .year)
        }.count
    }
}

// MARK: - Notification Manager

import UserNotifications

struct NotificationManager {
    static let shared = NotificationManager()

    private static let trialReminderID = "gopilates.trial_end_reminder"

    /// Schedules a single local notification for ~1 day before the 3-day free trial ends
    /// (today + 2 days at 10:00 local time). Requests permission on demand.
    func scheduleTrialEndReminder() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        let granted: Bool
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            granted = true
        case .notDetermined:
            granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            granted = false
        @unknown default:
            granted = false
        }
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
        let request = UNNotificationRequest(identifier: Self.trialReminderID, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [Self.trialReminderID])
        try? await center.add(request)
    }

    func cancelTrialEndReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.trialReminderID])
    }

    func toggleNotifications(enabled: Bool, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        if enabled {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                if granted {
                    self.scheduleDailyReminder()
                }
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            center.removeAllPendingNotificationRequests()
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    private func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "C'est l'heure de votre séance ! 🧘‍♀️"
        content.body = "Prenez 15 minutes pour vous aujourd'hui. Votre corps vous remerciera !"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 11 // Remind at 11:00 AM everyday

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyPilatesReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("[NotificationManager] Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Badge

enum Badge: String, CaseIterable, Identifiable {
    case firstSession    = "Première séance"
    case weekStreak      = "7 jours d'affilée"
    case hundredMinutes  = "100 minutes de Pilates"
    case challengeComplete = "Défi 30 jours terminé !"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firstSession:    return "star.fill"
        case .weekStreak:      return "flame.fill"
        case .hundredMinutes:  return "clock.fill"
        case .challengeComplete: return "trophy.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .firstSession:    return "DDB263"
        case .weekStreak:      return "E8B6C3"
        case .hundredMinutes:  return "E6C7B2"
        case .challengeComplete: return "DDB263"
        }
    }
}
