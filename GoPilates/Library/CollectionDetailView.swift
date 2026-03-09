import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let collection: PilatesCollection
    @EnvironmentObject var userProfile: UserProfile
    @State private var showPlayer = false
    @State private var appear = false

    private var safeExercises: [PilatesExercise] {
        collection.exercises.filter { userProfile.isExerciseSafe($0) }
    }

    private func durationLabel(_ seconds: Int) -> String {
        if seconds >= 60 { return "\(seconds / 60) min" }
        return "\(seconds)s"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.champagneBlush.opacity(0.4), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero card
                    heroSection
                    // Exercise list
                    exerciseList
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            // Floating start button
            VStack {
                Spacer()
                GoldButton(title: "Commencer le programme") {
                    showPlayer = true
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayer) {
            WorkoutPlayerView(
                exercises: safeExercises,
                sessionTitle: collection.title
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appear = true }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [collection.color.opacity(0.7), collection.color.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 120, height: 120)
                .offset(x: 80, y: -30)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: collection.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                    Spacer()
                    Text(collection.duration)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text(collection.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(collection.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))

                HStack(spacing: 12) {
                    Label("\(safeExercises.count) exercices", systemImage: "list.bullet")
                    if safeExercises.count < collection.exercises.count {
                        Label("Adapté à vos blessures", systemImage: "heart.shield.fill")
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.95)
    }

    // MARK: - Exercise List
    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercices du programme")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.deepCharcoal)
                .opacity(appear ? 1 : 0)

            ForEach(Array(safeExercises.enumerated()), id: \.element.id) { index, exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    HStack(spacing: 14) {
                        // Number badge
                        ZStack {
                            Circle()
                                .fill(collection.color.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(collection.color)
                        }

                        // Category SF Symbol icon — no stick figure
                        Image(systemName: categoryIconName(exercise.category))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(collection.color)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(exercise.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.deepCharcoal)
                                .lineLimit(1)
                            HStack(spacing: 8) {
                                Text(durationLabel(exercise.duration))
                                    .font(.system(size: 12))
                                    .foregroundColor(.deepCharcoal.opacity(0.55))
                                Text("·")
                                    .foregroundColor(.deepCharcoal.opacity(0.3))
                                Text(exercise.difficulty.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: exercise.difficulty.color))
                            }
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.deepCharcoal.opacity(0.25))
                    }
                    .padding(14)
                    .glassCard()
                }
                .buttonStyle(.plain)
                .opacity(appear ? 1 : 0)
                .offset(x: appear ? 0 : 30)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06 + 0.2), value: appear)
            }
        }
        .padding(.bottom, 80) // space for floating button
    }
}

#Preview {
    NavigationView {
        CollectionDetailView(collection: PilatesCollection.allCollections[0])
            .environmentObject(UserProfile())
    }
}
