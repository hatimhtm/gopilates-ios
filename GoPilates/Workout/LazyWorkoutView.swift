import SwiftUI

// MARK: - Lazy Workout View (Bed Pilates)

struct LCG: RandomNumberGenerator {
    var seed: UInt64
    mutating func next() -> UInt64 {
        seed = 2862933555777941757 &* seed &+ 3037000493
        return seed
    }
}

struct LazyWorkoutView: View {
    @EnvironmentObject var userProfile: UserProfile
    var onComplete: (() -> Void)?

    @Environment(\.presentationMode) var presentationMode
    @State private var showPlayer = false

    private var dailyExercises: [PilatesExercise] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        
        var hasher = Hasher()
        hasher.combine(dateString)
        let seed = UInt64(bitPattern: Int64(hasher.finalize()))
        var prng = LCG(seed: seed)
        
        let safePool = ExerciseCatalog.vod.filter { 
            ($0.difficulty == .beginner || $0.isBedPilates || $0.isWallPilates) &&
            userProfile.isExerciseSafe($0)
        }
        
        let shuffled = safePool.shuffled(using: &prng)
        return Array(shuffled.prefix(5))
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Softer background
                LinearGradient(
                    colors: [
                        Color(hex: "FFF8F5"),
                        Color.champagneBlush.opacity(0.7),
                        Color(hex: "FFF5F0")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        encouragementCard
                        exerciseList
                        startButton
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.deepCharcoal)
                    }
                }
            }
            .sheet(isPresented: $showPlayer) {
                WorkoutPlayerView(
                    exercises: dailyExercises,
                    sessionTitle: "Séance Douce",
                    onComplete: {
                        userProfile.markSeanceDouceCompletedToday()
                        onComplete?()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 40))
                .foregroundColor(.vintagePink)

            Text("Seance Douce")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.deepCharcoal)

            Text("10 minutes de Pilates au lit")
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal.opacity(0.6))
        }
        .padding(.top, 16)
    }

    // MARK: - Encouragement Card

    private var encouragementCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(.metallicGold)

            Text("Cette seance compte pour votre streak !")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepCharcoal)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.metallicGold.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.metallicGold.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: 12) {
            ForEach(Array(dailyExercises.enumerated()), id: \.offset) { index, exercise in
                exerciseRow(index: index + 1, exercise: exercise)
            }
        }
    }

    private func exerciseRow(index: Int, exercise: PilatesExercise) -> some View {
        HStack(spacing: 14) {
            // Number circle
            ZStack {
                Circle()
                    .fill(Color.vintagePink.opacity(0.2))
                    .frame(width: 36, height: 36)
                Text("\(index)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.vintagePink)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.deepCharcoal)

                HStack(spacing: 8) {
                    Label("\(exercise.duration)s", systemImage: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.deepCharcoal.opacity(0.5))

                    Text(exercise.targetMuscles.prefix(2).joined(separator: ", "))
                        .font(.system(size: 12))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: exercise.sfSymbol)
                .font(.system(size: 18))
                .foregroundColor(.vintagePink.opacity(0.5))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.6))
        )
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button(action: {
            HapticManager.notification(.success)
            showPlayer = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                Text(userProfile.hasCompletedTodaySeanceDouce ? "Refaire la séance" : "Commencer la séance")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.vintagePink)
            )
            .shadow(color: Color.vintagePink.opacity(0.3), radius: 15, x: 0, y: 8)
        }
    }
}
