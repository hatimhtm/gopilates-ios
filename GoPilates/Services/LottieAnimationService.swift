import SwiftUI

// MARK: - Exercise Animation Mapping
func animationName(for category: ExerciseCategory) -> String { "" }

// MARK: - Category Icon Helper
// Returns a premium SF Symbol for each exercise category (module-internal for shared use)
func exerciseCategoryIcon(_ category: ExerciseCategory) -> String {
    switch category {
    case .coreIntegration:  return "figure.core.training"
    case .lowerBody:        return "figure.walk"
    case .upperBody:        return "figure.arms.open"
    case .fullBody:         return "figure.pilates"
    case .classical:        return "figure.gymnastics"
    case .restorative:      return "figure.mind.and.body"
    }
}

// Alias used by CollectionDetailView
func categoryIconName(_ category: ExerciseCategory) -> String {
    exerciseCategoryIcon(category)
}

func categoryGradientColors(for category: ExerciseCategory) -> [Color] {
    switch category {
    case .coreIntegration: return [Color(hex: "F2C4D0"), Color(hex: "C4788A")]
    case .lowerBody:       return [Color(hex: "F0D5A0"), Color(hex: "B8893A")]
    case .upperBody:       return [Color(hex: "A8C4DC"), Color(hex: "5A7A96")]
    case .fullBody:        return [Color(hex: "B0D4B8"), Color(hex: "6E9A78")]
    case .classical:       return [Color(hex: "D4B0D4"), Color(hex: "A86E96")]
    case .restorative:     return [Color(hex: "C0D0DC"), Color(hex: "8A9CB0")]
    }
}

// MARK: - Exercise Illustration Card (Premium animated card for ExerciseDetailView / VOD)
struct ExerciseAnimationCard: View {
    let exercise: PilatesExercise
    @State private var appear = false
    @State private var pulse = false
    @State private var rotate: Double = 0

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: categoryGradientColors(for: exercise.category),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 130)
                .offset(x: 80, y: -15)
                .scaleEffect(pulse ? 1.12 : 1.0)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 90)
                .offset(x: -10, y: 50)
                .scaleEffect(pulse ? 0.88 : 1.0)

            // Spinning accent ring
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(
                    AngularGradient(
                        colors: [Color.white.opacity(0), Color.white.opacity(0.35), Color.white.opacity(0)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 150)
                .rotationEffect(.degrees(rotate))

            // Central premium icon (NO stick figure)
            VStack(spacing: 12) {
                GIFView(exercise: exercise)
                    .frame(width: 140, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaleEffect(appear ? 1.0 : 0.4)
                    .opacity(appear ? 1 : 0)

                Text(exercise.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .opacity(appear ? 1 : 0)
            }

            // Muscle tags
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(exercise.targetMuscles.prefix(3), id: \.self) { muscle in
                            HStack(spacing: 3) {
                                Circle().fill(Color.white).frame(width: 4, height: 4)
                                Text(muscle)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 14)
            }

            // Difficulty badge
            VStack {
                HStack {
                    Spacer()
                    Text(exercise.difficulty.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.25)))
                        .padding(14)
                }
                Spacer()
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: categoryGradientColors(for: exercise.category).last?.opacity(0.3) ?? .clear, radius: 18, y: 10)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { appear = true }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) { rotate = 360 }
        }
    }
}

// MARK: - Inline Exercise Demo (Workout Player — Immersive Full-Width)
struct InlineExerciseDemoView: View {
    let exercise: PilatesExercise
    @State private var appear = false

    private var categoryColor: Color {
        categoryGradientColors(for: exercise.category).first ?? Color.vintagePink
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Immersive full-width video block
            GIFView(exercise: exercise)
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(appear ? 1 : 0)

            // Gradient fade out to blend into the background floor smoothly
            LinearGradient(
                colors: [Color.clear, Color.champagneBlush.opacity(0.8), Color.champagneBlush],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            
            // Category label overlapping the gradient
            Text(exercise.category.frenchLabel.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(categoryColor)
                .tracking(2)
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                appear = true
            }
        }
    }
}

// MARK: - Exercise Grid Thumbnail (no stick figure)
struct ExerciseGridThumbnail: View {
    let exercise: PilatesExercise

    private var categoryColor: Color {
        categoryGradientColors(for: exercise.category).first ?? Color.vintagePink
    }

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [categoryColor.opacity(0.22), categoryColor.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Placeholder in case image is missing
            Color.clear.frame(height: 110) // ensures stable height

            // Premium SF Symbol
            Image(systemName: exerciseCategoryIcon(exercise.category))
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(categoryColor.opacity(0.85))
        }
        .frame(height: 110) // stable fixed height prevents grid jumps
        .clipped()
    }
}
