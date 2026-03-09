import SwiftUI

struct OnboardingFullScreenQ1View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        ValidationQuestionView(
            step: 33,
            question: "Est-il important pour vous de vous sentir plus confiante dans vos vêtements ?",
            onNext: onNext,
            onBack: onBack
        )
    }
}

struct OnboardingFullScreenQ2View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        ValidationQuestionView(
            step: 34,
            question: "Souhaitez-vous une méthode qui s'adapte réellement à votre emploi du temps ?",
            onNext: onNext,
            onBack: onBack
        )
    }
}

struct OnboardingFullScreenQ3View: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        ValidationQuestionView(
            step: 35,
            question: "Êtes-vous prête à consacrer 15 minutes par jour pour transformer votre corps ?",
            onNext: onNext,
            onBack: onBack
        )
    }
}

struct ValidationQuestionView: View {
    let step: Int
    let question: String
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        OnboardingScreenLayout(step: step, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer()

                Text(question)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(8)

                Spacer()

                VStack(spacing: 16) {
                    SuivantButton(title: "Oui, absolument", isEnabled: true, action: onNext)

                    Button(action: onNext) {
                        Text("Pas vraiment")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
