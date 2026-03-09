import Foundation
import Combine
import Observation

// MARK: - Workout Timer Service

@Observable
class WorkoutTimerService {
    var timeRemaining: Int = 45
    var isResting: Bool = false
    var isPaused: Bool = false
    var currentExerciseIndex: Int = 0
    var isWorkoutComplete: Bool = false
    var totalElapsedSeconds: Int = 0

    let effortDuration: Int
    let restDuration: Int

    private var cancellable: AnyCancellable?
    private var exercises: [PilatesExercise] = []

    init(effortDuration: Int = 45, restDuration: Int = 15) {
        self.effortDuration = effortDuration
        self.restDuration = restDuration
        self.timeRemaining = effortDuration
    }

    // MARK: - Public Interface

    func start(with exercises: [PilatesExercise]) {
        self.exercises = exercises
        self.currentExerciseIndex = 0
        self.isResting = false
        self.isPaused = false
        self.isWorkoutComplete = false
        self.totalElapsedSeconds = 0
        self.timeRemaining = effortDuration

        AudioManager.shared.setupSession()
        AudioManager.shared.speak("C'est parti ! \(exercises.first?.name ?? "Pilates")")
        startTimer()
    }

    func pause() {
        isPaused = true
        cancellable?.cancel()
    }

    func resume() {
        isPaused = false
        startTimer()
    }

    func togglePause() {
        if isPaused { resume() } else { pause() }
    }

    func skip() {
        cancellable?.cancel()
        advanceToNextExercise()
    }

    func stop() {
        cancellable?.cancel()
        AudioManager.shared.stopSpeaking()
        AudioManager.shared.deactivateSession()
    }

    // MARK: - Computed Properties

    var currentExercise: PilatesExercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var exerciseCount: Int { exercises.count }

    var totalDurationMinutes: Int { totalElapsedSeconds / 60 }

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        let completedExercises = Double(currentExerciseIndex)
        let currentProgress: Double
        if isResting {
            currentProgress = 1.0
        } else {
            let elapsed = Double(effortDuration - timeRemaining)
            currentProgress = elapsed / Double(effortDuration)
        }
        return (completedExercises + currentProgress) / Double(exercises.count)
    }

    var stateLabel: String {
        if isWorkoutComplete { return "Terminé !" }
        if isPaused { return "En pause" }
        if isResting { return "Repos" }
        return "Effort"
    }

    var estimatedCalories: Double {
        // MET-based formula: kcal = MET × weight(kg) × time(hours)
        // Pilates MET ≈ 3.5. Default user weight = 65 kg.
        let exerciseSeconds = Double(currentExerciseIndex) * Double(effortDuration)
            + Double(max(0, effortDuration - timeRemaining))
        let hours = exerciseSeconds / 3600.0
        let kcal = 3.5 * 65.0 * hours
        return max(15, kcal)
    }

    // MARK: - Private

    private func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard !isPaused else { return }

        totalElapsedSeconds += 1

        if timeRemaining > 0 {
            timeRemaining -= 1

            if timeRemaining == 3 && !isResting {
                HapticManager.impact(.light)
            }
        } else {
            HapticManager.impact(.heavy)

            if !isResting {
                isResting = true
                timeRemaining = restDuration
                AudioManager.shared.speak(nextExerciseCue())
            } else {
                advanceToNextExercise()
            }
        }
    }

    private func advanceToNextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            isResting = false
            timeRemaining = effortDuration
            AudioManager.shared.speak("C'est parti ! \(exercises[currentExerciseIndex].name)")
            startTimer()
        } else {
            isWorkoutComplete = true
            cancellable?.cancel()
            HapticManager.notification(.success)
            AudioManager.shared.speakEncouragement("Bravo ! Séance terminée. Vous êtes formidable !")
        }
    }

    private func nextExerciseCue() -> String {
        let next = currentExerciseIndex + 1
        if next < exercises.count {
            return "Repos. Préparez-vous pour \(exercises[next].name)"
        }
        return "Repos. Dernière série !"
    }
}
