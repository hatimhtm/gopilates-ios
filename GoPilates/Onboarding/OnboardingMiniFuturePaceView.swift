import SwiftUI

struct OnboardingMiniFuturePaceView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 18, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // Big stat
                Text("19 jours a l'avance !")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                Spacer().frame(height: 16)

                Text("\(data.projectedWeightString) d'ici \(data.targetDateString)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.metallicGold)
                    .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                // Mini progress visual
                HStack(spacing: 4) {
                    ForEach(0..<12, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i < 9 ? Color.vintagePink : Color.nudeModern.opacity(0.3))
                            .frame(height: 8 + CGFloat(i) * 2)
                    }
                }
                .frame(height: 36)
                .padding(.horizontal, 48)
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                Text("Nos donnees montrent que pour les femmes dans votre tranche d'age, une bonne alimentation et de l'exercice apres une semaine donnent deja des resultats visibles.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
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
    OnboardingMiniFuturePaceView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
