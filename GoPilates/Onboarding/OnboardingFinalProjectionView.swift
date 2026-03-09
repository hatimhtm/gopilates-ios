import SwiftUI

struct OnboardingFinalProjectionView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 37, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Votre plan est prêt !")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .padding(.top, 12)

                // Success stars Lottie animation
                LottieView(animationName: "onboarding_success", loopMode: .playOnce, animationSpeed: 1.0)
                    .frame(width: 120, height: 120)

                Spacer().frame(height: 20)

                // Summary card
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Objectif de poids")
                            .font(.system(size: 14))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                        Text("\(String(format: "%.1f", data.targetWeightKg))kg")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.metallicGold)
                    }

                    Divider().padding(.horizontal, 40)

                    VStack(spacing: 8) {
                        Text("Date estimée")
                            .font(.system(size: 14))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                        Text(data.targetDateString)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.deepCharcoal)
                    }
                    
                    HStack(spacing: 20) {
                        SummaryStat(label: "Plan", value: "12 sem.")
                        SummaryStat(label: "Niveau", value: data.fitnessLevel)
                        SummaryStat(label: "Focus", value: data.focusAreas.count > 1 ? "Mixte" : (data.focusAreas.first ?? "Total"))
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(title: "Voir mon programme", isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct SummaryStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.deepCharcoal.opacity(0.4))
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.deepCharcoal)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingFinalProjectionView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
