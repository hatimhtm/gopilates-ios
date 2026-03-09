import SwiftUI

struct OnboardingMotivationView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("heart.fill", "Remise en forme"),
        ("figure.stand", "Avoir un meilleur physique"),
        ("leaf.fill", "Reduire le stress et detente"),
        ("moon.fill", "Dormez mieux"),
        ("star.fill", "Trouver l'ideal de soi")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 1, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Qu'est-ce qui vous\nmotive le plus ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(options, id: \.1) { icon, title in
                            OnboardingOptionCard(
                                title: title,
                                icon: icon,
                                isSelected: data.motivation == title
                            ) {
                                data.motivation = title
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }

                Spacer()
            }

            VStack {
                Spacer()
                SuivantButton(isEnabled: !data.motivation.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingMotivationView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
