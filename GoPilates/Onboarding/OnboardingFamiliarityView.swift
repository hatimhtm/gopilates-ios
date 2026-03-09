import SwiftUI

struct OnboardingFamiliarityView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("ear.fill", "J'ai a peine entendu parler"),
        ("hand.raised.fill", "J'ai fait plusieurs fois"),
        ("star.circle.fill", "Je suis experimentee")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 2, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Etes-vous familiere\navec le Pilates ?")
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
                            isSelected: data.familiarity == title
                        ) {
                            data.familiarity = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.familiarity.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingFamiliarityView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
