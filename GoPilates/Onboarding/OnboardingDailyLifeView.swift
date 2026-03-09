import SwiftUI

struct OnboardingDailyLifeView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("desktopcomputer", "Au travail, principalement assise"),
        ("house.fill", "A la maison, principalement inactive"),
        ("figure.walk", "Je marche souvent"),
        ("figure.stand", "Debout la majorite du temps")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 19, onBack: onBack) {
            VStack(spacing: 0) {
                Text("A quoi ressemble l'une\nde vos journees types ?")
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
                            isSelected: data.dailyLife == title
                        ) {
                            data.dailyLife = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.dailyLife.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingDailyLifeView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
