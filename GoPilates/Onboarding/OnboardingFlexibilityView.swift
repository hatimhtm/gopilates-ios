import SwiftUI

struct OnboardingFlexibilityView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("xmark.circle", "Je suis tres raide"),
        ("arrow.down.to.line", "Loin de mes pieds"),
        ("arrow.down", "Pres de mes pieds"),
        ("checkmark.circle", "Je touche facilement")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 23, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Jusqu'ou pouvez-vous\nfaire une flexion\navant assise ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 16)

                // Flexibility illustration
                Image(systemName: "figure.cooldown")
                    .font(.system(size: 56))
                    .foregroundColor(.vintagePink)
                    .frame(height: 80)

                Spacer().frame(height: 20)

                VStack(spacing: 12) {
                    ForEach(options, id: \.1) { icon, title in
                        OnboardingOptionCard(
                            title: title,
                            icon: icon,
                            isSelected: data.flexibility == title
                        ) {
                            data.flexibility = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.flexibility.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingFlexibilityView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
