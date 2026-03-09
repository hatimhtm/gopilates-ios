import SwiftUI

struct OnboardingSocialProof100kView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 29, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("Le Pilates a aide plus de")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 8)

                Text("100k+")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.metallicGold)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)

                Text("personnes comme vous !")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                // Logo/brand mark placeholder - lotus-like shape
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.vintagePink.opacity(0.3), Color.champagneBlush],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 100)

                    // Lotus petals using overlapping ellipses
                    ForEach(0..<5, id: \.self) { i in
                        Ellipse()
                            .fill(Color.vintagePink.opacity(0.4))
                            .frame(width: 24, height: 40)
                            .rotationEffect(.degrees(Double(i) * 72 - 90))
                            .offset(y: -12)
                    }

                    Text("GP")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                }
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                Text("La grande majorité de nos utilisatrices constatent des changements visibles dès les premières semaines de programme.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
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
    OnboardingSocialProof100kView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
