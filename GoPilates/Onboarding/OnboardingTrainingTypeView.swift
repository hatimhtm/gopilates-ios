import SwiftUI

struct OnboardingTrainingTypeView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("figure.walk", "Sans equipement"),
        ("leaf.fill", "Leger et doux"),
        ("arrow.triangle.2.circlepath", "Exercices alternatifs"),
        ("hand.thumbsup.fill", "Peu importe")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 15, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel est ton type\nd'entrainement prefere ?")
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
                            isSelected: data.trainingType == title
                        ) {
                            data.trainingType = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.trainingType.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingTrainingTypeView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
