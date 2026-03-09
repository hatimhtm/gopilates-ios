import SwiftUI

struct OnboardingAffirmation1View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        AffirmationScreenView(
            step: 25,
            title: "Vous identifiez-vous à l'affirmation ci-dessous ?",
            affirmation: "Je ne sais pas toujours comment choisir les bons entraînements pour moi.",
            onYes: {
                data.affirmation1 = true
                onNext()
            },
            onNo: {
                data.affirmation1 = false
                onNext()
            },
            onBack: onBack
        )
    }
}

struct OnboardingAffirmation2View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        AffirmationScreenView(
            step: 26,
            title: "Vous identifiez-vous à l'affirmation ci-dessous ?",
            affirmation: "J'abandonne souvent lorsque les entraînements sont trop difficiles ou que je manque de motivation.",
            onYes: {
                data.affirmation2 = true
                onNext()
            },
            onNo: {
                data.affirmation2 = false
                onNext()
            },
            onBack: onBack
        )
    }
}

struct OnboardingAffirmation3View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        AffirmationScreenView(
            step: 27,
            title: "Vous identifiez-vous à l'affirmation ci-dessous ?",
            affirmation: "J'aurais plus de résultats avec un programme personnalisé et un suivi régulier.",
            onYes: {
                data.affirmation3 = true
                onNext()
            },
            onNo: {
                data.affirmation3 = false
                onNext()
            },
            onBack: onBack
        )
    }
}

struct OnboardingAffirmation4View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        AffirmationScreenView(
            step: 28,
            title: "Vous identifiez-vous à l'affirmation ci-dessous ?",
            affirmation: "Faire de l'exercice dans le cadre d'une routine solide m'aiderait vraiment à progresser.",
            onYes: {
                data.affirmation4 = true
                onNext()
            },
            onNo: {
                data.affirmation4 = false
                onNext()
            },
            onBack: onBack
        )
    }
}

// MARK: - Shared Affirmation Screen (No typewriter — instant text, static layout)

struct AffirmationScreenView: View {
    let step: Int
    let title: String
    let affirmation: String
    let onYes: () -> Void
    let onNo: () -> Void
    let onBack: () -> Void

    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: step, onBack: onBack) {
            VStack(spacing: 0) {
                // Static question header — never moves
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .frame(height: 60)

                Spacer()

                // Static quote mark — never moves
                Text("\u{201C}")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.metallicGold)

                // Affirmation text — instant, centered, fixed frame so layout is stable
                Text(affirmation)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .frame(minHeight: 120)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Static Yes / No buttons — always at the same position
                HStack(spacing: 16) {
                    // Non button
                    Button(action: {
                        HapticManager.impact(.light)
                        onNo()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Non")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.deepCharcoal.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.deepCharcoal.opacity(0.2), lineWidth: 1.5)
                        )
                    }

                    // Oui button
                    Button(action: {
                        HapticManager.impact(.medium)
                        onYes()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Oui")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.deepCharcoal)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
        }
    }
}

#Preview {
    OnboardingAffirmation1View(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
