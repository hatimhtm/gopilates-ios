import SwiftUI

struct OnboardingSocialProofMidView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false
    @State private var countUp: Double = 0

    var body: some View {
        OnboardingScreenLayout(step: 22, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                Text("Nous avons aide")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .opacity(showContent ? 1 : 0)

                Text("87 965+")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.metallicGold)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.7)

                Text("personnes comme vous a\natteindre leurs objectifs !")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                // Illustration placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.vintagePink.opacity(0.4), Color.champagneBlush],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)

                    Image(systemName: "figure.yoga")
                        .font(.system(size: 56))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 24)

                // Testimonial
                VStack(spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 20))
                        .foregroundColor(.vintagePink)

                    Text("En seulement 4 semaines, j'ai retrouve ma confiance. Le programme est vraiment adapte a mon niveau.")
                        .font(.system(size: 14, weight: .regular).italic())
                        .foregroundColor(.deepCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)

                    Text("- Marie, 34 ans")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                }
                .padding(.horizontal, 32)
                .opacity(showContent ? 1 : 0)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                showContent = true
            }
        }
    }
}

#Preview {
    OnboardingSocialProofMidView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
