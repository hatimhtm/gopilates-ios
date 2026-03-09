import SwiftUI

struct OnboardingGoalView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("scalemass.fill", "Perdre du poids"),
        ("figure.run", "Remise en forme"),
        ("dumbbell.fill", "Renforcez vos muscles"),
        ("heart.text.square.fill", "Ameliorer votre sante"),
        ("figure.flexibility", "Ameliorer la flexibilite"),
        ("figure.stand", "Affiner la posture")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 3, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel est votre\nobjectif principal ?")
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
                                isSelected: data.mainGoal == title
                            ) {
                                data.mainGoal = title
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
                SuivantButton(isEnabled: !data.mainGoal.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingGoalView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
