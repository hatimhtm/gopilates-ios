import SwiftUI
import AudioToolbox

// MARK: - Workout Player View (Full-Screen Immersive)

struct WorkoutPlayerView: View {
    let exercises: [PilatesExercise]
    let sessionTitle: String
    var onComplete: (() -> Void)?

    @EnvironmentObject var userProfile: UserProfile
    @State private var timer = WorkoutTimerService()
    @Environment(\.dismiss) private var dismiss
    @State private var showCompletionSheet = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.champagneBlush,
                    Color(hex: "FFF5F0"),
                    Color.champagneBlush.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .zIndex(1)
                exerciseAnimationArea
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                Spacer(minLength: 0)
                bottomPanel
            }
        }
        .onAppear {
            timer.start(with: exercises)
        }
        .onDisappear {
            timer.stop()
        }
        .onChange(of: timer.isWorkoutComplete) { _, completed in
            if completed {
                showCompletionSheet = true
            }
        }
        .fullScreenCover(isPresented: $showCompletionSheet) {
            BravoCompletionView(
                totalSeconds: timer.totalElapsedSeconds,
                estimatedCalories: Int(timer.estimatedCalories),
                exerciseCount: exercises.count,
                onDismiss: {
                    // Log session to UserProfile
                    userProfile.completeSession(durationMinutes: timer.totalDurationMinutes)
                    // Mark each completed exercise as done today (greyed out until midnight)
                    for exercise in exercises {
                        userProfile.markWorkoutCompletedToday(exercise.id)
                    }
                    onComplete?()
                    showCompletionSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            )
        }
        .statusBar(hidden: true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: {
                HapticManager.impact(.light)
                timer.stop()
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Spacer()

            Text(sessionTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            Spacer()

            Button(action: {
                HapticManager.selection()
                timer.togglePause()
            }) {
                Image(systemName: timer.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Exercise Animation Area

    private var exerciseAnimationArea: some View {
        VStack(spacing: 12) {
            if let exercise = timer.currentExercise {
                // Immersive full width presentation
                InlineExerciseDemoView(exercise: exercise)
                    // Take the 260 container height natively without restricting width to 200
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false) // Prevent video player from stealing touches
                    .opacity(timer.isResting ? 0.7 : 1.0)
                    .animation(.easeInOut(duration: 0.4), value: timer.isResting)

                HStack(spacing: 8) {
                    ForEach(exercise.targetMuscles.prefix(3), id: \.self) { muscle in
                        Text(muscle)
                            .font(.system(size: 11))
                            .foregroundColor(.deepCharcoal.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.5)))
                    }
                }
                .frame(height: 28)
            } else {
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.nudeModern.opacity(0.3))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.metallicGold)
                        .frame(width: max(0, geo.size.width * timer.progress), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: timer.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        // Fixed-height bottom panel — nothing inside changes its height
        VStack(spacing: 14) {
            // State label — fixed height so color change doesn't cause jitter
            Text(timer.stateLabel)
                .font(.system(size: 14, weight: .medium))
                .tracking(2)
                .foregroundColor(timer.isResting ? .vintagePink : .metallicGold)
                .textCase(.uppercase)
                .frame(height: 18)
                .animation(.easeInOut(duration: 0.25), value: timer.isResting)

            // Exercise name — fixedSize prevents layout recalculation
            if let exercise = timer.currentExercise {
                Text(exercise.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 54)
            } else {
                Color.clear.frame(height: 54)
            }

            // Timer — monospacedDigit prevents width bounce
            Text(timerText)
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .foregroundColor(.metallicGold)
                .monospacedDigit()
                .frame(height: 90)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: timer.timeRemaining)

            Text("Exercice \(timer.currentExerciseIndex + 1) / \(timer.exerciseCount)")
                .font(.system(size: 13))
                .foregroundColor(.deepCharcoal.opacity(0.5))
                .frame(height: 18)

            exerciseProgressPills

            Button(action: {
                HapticManager.impact(.medium)
                timer.skip()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 12))
                    Text("Passer")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.deepCharcoal.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.4)))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 20, y: -10)
        )
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Exercise Progress Pills

    private var exerciseProgressPills: some View {
        GeometryReader { geo in
            let count = max(1, exercises.count)
            let totalSpacing = CGFloat(count - 1) * 6
            let availableWidth = max(0, geo.size.width - totalSpacing)
            // Make the active pill 3x wider than inactive ones
            let inactiveWidth = availableWidth / CGFloat(count + 2)
            let activeWidth = inactiveWidth * 3

            HStack(spacing: 6) {
                ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(pillColor(for: index))
                        .frame(
                            width: index == timer.currentExerciseIndex ? activeWidth : inactiveWidth,
                            height: index == timer.currentExerciseIndex ? 8 : 4
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: timer.currentExerciseIndex)
                }
            }
        }
        .frame(height: 8)
    }

    private func pillColor(for index: Int) -> Color {
        if index < timer.currentExerciseIndex {
            return Color.metallicGold
        } else if index == timer.currentExerciseIndex {
            return timer.isResting ? Color.vintagePink : Color.metallicGold
        } else {
            return Color.nudeModern.opacity(0.4)
        }
    }

    // MARK: - Timer Text

    private var timerText: String {
        let minutes = timer.timeRemaining / 60
        let seconds = timer.timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)"
    }
}

// MARK: - Bravo Completion View (Animated)

struct BravoCompletionView: View {
    let totalSeconds: Int
    let estimatedCalories: Int
    let exerciseCount: Int
    var onDismiss: () -> Void

    @State private var appear = false
    @State private var animatedCalories: Int = 0
    @State private var animatedExercises: Int = 0
    @State private var showConfetti = false

    private var durationLabel: String {
        if totalSeconds >= 60 {
            return "\(totalSeconds / 60)"
        } else {
            return "0:\(String(format: "%02d", totalSeconds))"
        }
    }
    
    private var durationUnit: String {
        totalSeconds >= 60 ? "min" : ""
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.champagneBlush, Color(hex: "FFF5F0"), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating Confetti Circles
            if showConfetti {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(confettiColor(i))
                        .frame(width: CGFloat.random(in: 6...14))
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: -400...400)
                        )
                        .opacity(Double.random(in: 0.3...0.7))
                        .animation(
                            .spring(response: Double.random(in: 2...4), dampingFraction: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...1)),
                            value: showConfetti
                        )
                }
            }

            VStack(spacing: 28) {
                Spacer()

                // Trophy icon with glow
                ZStack {
                    Circle()
                        .fill(Color.metallicGold.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(appear ? 1 : 0.3)
                    
                    Circle()
                        .fill(Color.metallicGold.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .scaleEffect(appear ? 1 : 0.2)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.metallicGold)
                        .scaleEffect(appear ? 1 : 0)
                        .rotationEffect(.degrees(appear ? 0 : -30))
                }

                VStack(spacing: 8) {
                    Text("Bravo ! 🎉")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)

                    Text("Séance terminée avec succès")
                        .font(.system(size: 16))
                        .foregroundColor(.deepCharcoal.opacity(0.7))
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 15)
                }

                // Animated Stats
                HStack(spacing: 20) {
                    animatedStatCard(
                        value: durationLabel,
                        label: durationUnit,
                        icon: "clock.fill",
                        color: .vintagePink
                    )
                    animatedStatCard(
                        value: "\(animatedCalories)",
                        label: "kcal",
                        icon: "flame.fill",
                        color: .metallicGold
                    )
                    animatedStatCard(
                        value: "\(animatedExercises)",
                        label: "exos",
                        icon: "figure.pilates",
                        color: .deepCharcoal
                    )
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
                .padding(.horizontal, 24)

                Spacer()

                GoldButton(title: "Terminer") {
                    onDismiss()
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 40)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
                appear = true
            }

            // Confetti
            withAnimation(.easeInOut.delay(0.5)) {
                showConfetti = true
                // Play a success sound
                AudioServicesPlaySystemSound(1322) // System success chime
                // Give a heavy haptic pop
                HapticManager.impact(.heavy)
            }

            // Animated counters
            animateCounter(to: estimatedCalories, current: $animatedCalories, duration: 2.0)
            animateCounter(to: exerciseCount, current: $animatedExercises, duration: 1.0)
        }
    }

    private func animatedStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.deepCharcoal)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }

    private func confettiColor(_ index: Int) -> Color {
        let colors: [Color] = [.vintagePink, .metallicGold, .nudeModern, .champagneBlush, .deepCharcoal.opacity(0.3)]
        return colors[index % colors.count]
    }

    private func animateCounter(to target: Int, current: Binding<Int>, duration: Double) {
        let steps = min(target, 30)
        guard steps > 0 else { return }
        let interval = duration / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i) + 0.5) {
                current.wrappedValue = Int(Double(target) * (Double(i) / Double(steps)))
            }
        }
    }
}
