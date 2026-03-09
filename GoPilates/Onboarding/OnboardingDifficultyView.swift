import SwiftUI

struct OnboardingDifficultyView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("tortoise.fill", "Facile a commencer"),
        ("drop.fill", "Transpiration legere"),
        ("flame.fill", "Un peu exigeant")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 16, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel niveau de\ndifficulte preferes-tu ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 24)

                VStack(spacing: 12) {
                    ForEach(options, id: \.1) { icon, title in
                        OnboardingOptionCard(
                            title: title,
                            icon: icon,
                            isSelected: data.difficulty == title
                        ) {
                            data.difficulty = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.difficulty.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingDifficultyView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
