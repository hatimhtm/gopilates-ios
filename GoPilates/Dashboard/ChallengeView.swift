import SwiftUI

// MARK: - Challenge View (30-Day Challenge)

struct ChallengeView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var sessions: [DaySession] = []
    @State private var selectedDay: DaySession?
    @State private var showLazyWorkout = false
    @State private var showConfetti = false
    @State private var appear = false
    @State private var animatedProgress: CGFloat = 0
    @State private var animatedStreak: Int = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    var body: some View {
        NavigationView {
            ZStack {
                Color.champagneBlush.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        progressCard
                        calendarGrid
                        lazySessionButton
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                // Confetti overlay
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { showConfetti = false }
                            }
                        }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadSessions()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appear = true }
                // Animate progress ring
                withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                    animatedProgress = userProfile.challengeProgressPercent
                }
                // Count up streak
                animateStreakCounter()
            }
            // Use .sheet(item:) so WorkoutPlayerView always receives non-nil data
            .sheet(item: $selectedDay) { day in
                WorkoutPlayerView(
                    exercises: day.exercises,
                    sessionTitle: day.title,
                    onComplete: {
                        userProfile.completeChallengeDay(day.id)
                        loadSessions()
                        showConfetti = true
                    }
                )
            }
            .sheet(isPresented: $showLazyWorkout) {
                LazyWorkoutView(onComplete: {
                    loadSessions()
                    showConfetti = true
                    showLazyWorkout = false
                })
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Défi 30 Jours")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                Text("Votre transformation commence ici")
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
            }
            Spacer()
            if userProfile.currentStreak > 0 {
                streakBadge
            }
        }
        .padding(.top, 8)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.system(size: 16))
            Text("\(animatedStreak) jours")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.deepCharcoal)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            Capsule()
                .stroke(Color.metallicGold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        HStack(spacing: 20) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.nudeModern.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        Color.metallicGold,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.2), value: animatedProgress)

                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.deepCharcoal)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Jour \(userProfile.challengeDayCompleted) / 30")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.deepCharcoal)

                Text("\(userProfile.totalSessions) séances terminées")
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.6))

                Text("\(userProfile.totalMinutes) min au total")
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
            }

            Spacer()
        }
        .padding(20)
        .glassCard()
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: appear)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendrier")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    dayCell(for: session)
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1.0 : 0.8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.02), value: appear)
                }
            }
        }
        .padding(16)
        .glassCard()
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 32)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: appear)
    }

    private func dayCell(for session: DaySession) -> some View {
        let isToday = session.id == userProfile.challengeDayCompleted + 1
        let isCompleted = session.isCompleted
        let isLocked = !session.isUnlocked

        return Button(action: {
            guard session.isUnlocked else {
                HapticManager.notification(.error)
                return
            }
            HapticManager.selection()
            selectedDay = session
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(cellBackground(isCompleted: isCompleted, isToday: isToday, isLocked: isLocked))
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isToday ? Color.vintagePink : Color.clear,
                                lineWidth: 2
                            )
                    )

                if isCompleted {
                    // Gold shimmer overlay
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.0), Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 44)
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(session.id)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    }
                } else if isLocked {
                    VStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("\(session.id)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                } else {
                    Text("\(session.id)")
                        .font(.system(size: 14, weight: isToday ? .bold : .medium))
                        .foregroundColor(isToday ? Color.metallicGold : .deepCharcoal)
                }
            }
        }
        .disabled(isLocked)
    }

    private func cellBackground(isCompleted: Bool, isToday: Bool, isLocked: Bool) -> Color {
        if isCompleted { return Color.metallicGold }
        if isLocked { return Color.gray.opacity(0.1) }
        if isToday { return Color.white.opacity(0.9) }
        return Color.white.opacity(0.6)
    }

    // MARK: - Lazy Session Button

    private var lazySessionButton: some View {
        let isDone = userProfile.hasCompletedTodaySeanceDouce
        return Button(action: {
            HapticManager.selection()
            showLazyWorkout = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.vintagePink)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Séance Douce")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                    Text("10 min de Pilates au lit")
                        .font(.system(size: 12))
                        .foregroundColor(.deepCharcoal.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepCharcoal.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isDone ? Color.clear : Color.vintagePink.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isDone ? 0.6 : 1.0)
        .grayscale(isDone ? 0.8 : 0.0)
    }

    // MARK: - Data

    private func loadSessions() {
        sessions = WorkoutPlan.generate30DayPlan(
            completedDay: userProfile.challengeDayCompleted,
            daysSinceStart: userProfile.daysSinceChallengeStart
        )
    }

    private func animateStreakCounter() {
        let target = userProfile.currentStreak
        guard target > 0 else { return }
        let steps = min(target, 20)
        let interval = 1.0 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i) + 0.4) {
                animatedStreak = Int(Double(target) * (Double(i) / Double(steps)))
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color(hex: particle.colorHex))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear { generateParticles() }
    }

    private func generateParticles() {
        let screenWidth = (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width) ?? 400
        let colors = ["DDB263", "E8B6C3", "E6C7B2", "FDE2DB"]
        var newParticles: [ConfettiParticle] = []

        for i in 0..<40 {
            let startX = CGFloat.random(in: 0...screenWidth)
            let particle = ConfettiParticle(
                id: i,
                position: CGPoint(x: startX, y: -20),
                colorHex: colors.randomElement() ?? "DDB263",
                size: CGFloat.random(in: 6...12),
                opacity: 1.0
            )
            newParticles.append(particle)
        }

        particles = newParticles

        // Animate particles falling
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.5...2.5)
            let endY = CGFloat.random(in: 400...800)
            let drift = CGFloat.random(in: -50...50)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: duration)) {
                    if i < particles.count {
                        particles[i].position = CGPoint(
                            x: particles[i].position.x + drift,
                            y: endY
                        )
                        particles[i].opacity = 0
                    }
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    var position: CGPoint
    let colorHex: String
    let size: CGFloat
    var opacity: Double
}
