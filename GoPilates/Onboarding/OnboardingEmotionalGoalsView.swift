import SwiftUI

struct OnboardingEmotionalGoalsView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options = [
        "Ce serait formidable !",
        "Fiere et satisfaite de mon corps",
        "Pleine d'energie et de vitalite",
        "En meilleure sante",
        "Plus confiante"
    ]

    var body: some View {
        OnboardingScreenLayout(step: 31, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Comment vous\nsentiriez-vous lorsque\nvous atteindrez votre\npoids ideal ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 24)

                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        OnboardingMultiOptionCard(
                            title: option,
                            isSelected: data.emotionalGoals.contains(option)
                        ) {
                            if data.emotionalGoals.contains(option) {
                                data.emotionalGoals.remove(option)
                            } else {
                                data.emotionalGoals.insert(option)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.emotionalGoals.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingEmotionalGoalsView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
