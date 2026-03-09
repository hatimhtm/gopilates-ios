import SwiftUI

struct OnboardingFitnessLevelView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let levels: [(String, String, String)] = [
        ("figure.cooldown", "Debutante", "Je commence tout juste"),
        ("figure.yoga", "Intermediaire", "Je m'entraine regulierement"),
        ("figure.highintensity.intervaltraining", "Avancee", "Je suis tres entrainee")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 21, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel est votre niveau\nde forme physique ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 24)

                VStack(spacing: 14) {
                    ForEach(levels, id: \.1) { icon, title, desc in
                        ActivityLevelCard(
                            icon: icon,
                            title: title,
                            description: desc,
                            isSelected: data.fitnessLevel == title
                        ) {
                            HapticManager.selection()
                            data.fitnessLevel = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.fitnessLevel.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingFitnessLevelView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
