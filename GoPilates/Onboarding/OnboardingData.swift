import SwiftUI
import Observation

@Observable
class OnboardingData {
    // User Identity
    var userName: String = ""

    // Phase 1
    var motivation: String = ""
    var familiarity: String = ""
    var mainGoal: String = ""
    var focusAreas: Set<String> = []

    // Phase 2 (Physical)
    var heightCm: Int = 165
    var currentWeightKg: Double = 65.0
    var targetWeightKg: Double = 60.0
    var currentBodyType: Int = 1
    var targetBodyType: Int = 0
    var age: Int = 30

    // Phase 3 (Habits)
    var exerciseLocation: String = ""
    var trainingType: String = ""
    var difficulty: String = ""
    var injuries: Set<String> = []
    var dailyLife: String = ""

    // Phase 4 (Experience)
    var activityLevel: String = ""
    var fitnessLevel: String = ""
    var flexibility: String = ""
    var cardioFitness: String = ""

    // Phase 5 (Psycho/Goals)
    var affirmation1: Bool? = nil
    var affirmation2: Bool? = nil
    var affirmation3: Bool? = nil
    var affirmation4: Bool? = nil
    var rewards: Set<String> = []
    var emotionalGoals: Set<String> = []

    // MARK: - Computed Properties

    var bmi: Double {
        let heightMeters = Double(heightCm) / 100.0
        guard heightMeters > 0 else { return 0 }
        return currentWeightKg / (heightMeters * heightMeters)
    }

    var bmiCategory: String {
        let val = bmi
        if val < 18.5 { return "Insuffisance ponderale" }
        if val < 25 { return "Normal" }
        if val < 30 { return "Surpoids" }
        return "Obedite"
    }

    var weightDelta: Double {
        abs(currentWeightKg - targetWeightKg)
    }

    var targetDateString: String {
        let weeksNeeded = Int(weightDelta / 0.5)
        let date = Calendar.current.date(byAdding: .weekOfYear, value: max(12, weeksNeeded), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    var projectedWeightString: String {
        return String(format: "%.1fkg", targetWeightKg)
    }
}
