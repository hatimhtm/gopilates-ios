import Foundation
import HealthKit

// MARK: - HealthKit Manager (Singleton)

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let store = HKHealthStore()
    @Published var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[HealthKit] Health data not available on this device.")
            return
        }

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        store.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
            }
            if let error = error {
                print("[HealthKit] Authorization error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Save Workout

    func saveWorkout(duration: TimeInterval, calories: Double, completion: ((Bool) -> Void)? = nil) {
        guard isAuthorized else {
            completion?(false)
            return
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)

        let config = HKWorkoutConfiguration()
        config.activityType = .pilates

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        
        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                print("[HealthKit] Begin collection error: \(error?.localizedDescription ?? "unknown")")
                DispatchQueue.main.async { completion?(false) }
                return
            }

            // Add energy burned sample
            guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                DispatchQueue.main.async { completion?(false) }
                return
            }
            let energySample = HKQuantitySample(
                type: energyType,
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
                start: startDate,
                end: endDate
            )

            builder.add([energySample]) { _, _ in
                builder.endCollection(withEnd: endDate) { _, _ in
                    builder.finishWorkout { workout, error in
                        DispatchQueue.main.async {
                            completion?(workout != nil)
                        }
                        if let error = error {
                            print("[HealthKit] Save workout error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Save Energy Burned Sample

    func saveCaloriesBurned(_ calories: Double, duration: TimeInterval) {
        guard isAuthorized else { return }

        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)

        let sample = HKQuantitySample(
            type: energyType,
            quantity: quantity,
            start: startDate,
            end: endDate
        )

        store.save(sample) { _, error in
            if let error = error {
                print("[HealthKit] Save calories error: \(error.localizedDescription)")
            }
        }
    }
}
