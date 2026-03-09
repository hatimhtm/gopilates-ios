import SwiftUI

struct OnboardingPotentialView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 13, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                // Gradient card
                VStack(spacing: 24) {
                    // Sparkle icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(.metallicGold)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.5)

                    Text("Vous avez un grand potentiel pour atteindre vos objectifs !")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)

                    Text("Selon votre profil, vous avez toutes les qualites necessaires pour reussir. Avec un programme adapte et de la regularite, vos resultats seront visibles rapidement.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.deepCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.vintagePink.opacity(0.3), Color.champagneBlush],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

#Preview {
    OnboardingPotentialView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
