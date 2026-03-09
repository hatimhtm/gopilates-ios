import SwiftUI

struct OnboardingLocationView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("figure.yoga", "Sur le tapis"),
        ("bed.double.fill", "Sur le lit / canape"),
        ("mappin.and.ellipse", "Tous les lieux me conviennent")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 14, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Ou faites-vous\nhabituellement\nde l'exercice ?")
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
                            isSelected: data.exerciseLocation == title
                        ) {
                            data.exerciseLocation = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.exerciseLocation.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingLocationView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
