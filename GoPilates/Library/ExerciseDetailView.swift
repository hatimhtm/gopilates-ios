import SwiftUI

// MARK: - Exercise Detail View

struct ExerciseDetailView: View {
    let exercise: PilatesExercise

    @State private var showPlayer = false

    var body: some View {
        ZStack {
            Color.champagneBlush.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerImage
                    exerciseInfo
                    descriptionSection
                    targetMusclesSection
                    precautionsSection
                    startButton
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayer) {
            WorkoutPlayerView(
                exercises: [exercise],
                sessionTitle: exercise.name
            )
        }
    }

    // MARK: - Header Image (Lottie Animation)

    private var headerImage: some View {
        ExerciseAnimationCard(exercise: exercise)
            .padding(.top, 8)
    }

    // MARK: - Exercise Info

    private var exerciseInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(exercise.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.deepCharcoal)

            Text(exercise.englishName)
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal.opacity(0.5))
                .italic()

            HStack(spacing: 12) {
                // Category
                HStack(spacing: 4) {
                    Image(systemName: exercise.category.icon)
                        .font(.system(size: 12))
                    Text(exercise.category.frenchLabel)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.vintagePink)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(Color.vintagePink.opacity(0.15))
                )

                // Difficulty
                Text(exercise.difficulty.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: exercise.difficulty.color))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(Color(hex: exercise.difficulty.color).opacity(0.15))
                    )

                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("\(exercise.duration)s")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.deepCharcoal.opacity(0.6))
            }

            // Type badges
            if exercise.isWallPilates || exercise.isBedPilates {
                HStack(spacing: 8) {
                    if exercise.isWallPilates {
                        typeBadge(text: "Pilates Mural", icon: "square.fill")
                    }
                    if exercise.isBedPilates {
                        typeBadge(text: "Pilates au Lit", icon: "bed.double.fill")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func typeBadge(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.metallicGold)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(Color.metallicGold.opacity(0.1))
        )
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("À propos de cet exercice")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            Text(exercise.description)
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }

    // MARK: - Target Muscles

    private var targetMusclesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Muscles cibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            // Use a flexible flow layout that doesn't break words
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exercise.targetMuscles, id: \.self) { muscle in
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.vintagePink)
                            Text(muscle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.deepCharcoal)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color.white.opacity(0.6))
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }

    // MARK: - Precautions

    @ViewBuilder
    private var precautionsSection: some View {
        if let precautions = exercise.precautions {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.metallicGold)
                    Text("Précautions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                }

                Text(precautions)
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.metallicGold.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.metallicGold.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        GoldButton(title: "Commencer") {
            showPlayer = true
        }
        .padding(.top, 8)
    }
}

