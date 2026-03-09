import SwiftUI

struct OnboardingRewardView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("\u{1F457}", "Acheter de nouveaux vetements"),
        ("\u{1F37D}\u{FE0F}", "Profitez d'un repas delicieux"),
        ("\u{1F381}", "Me faire un beau cadeau"),
        ("\u{2708}\u{FE0F}", "Partir en voyage"),
        ("\u{1F4F8}", "Prendre des photos attractives"),
        ("\u{1F389}", "Feter ca avec des amis")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 30, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quelle est votre\nrecompense pour\navoir atteint votre\nobjectif de poids ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(options, id: \.1) { emoji, title in
                            OnboardingMultiOptionCard(
                                title: title,
                                emoji: emoji,
                                isSelected: data.rewards.contains(title)
                            ) {
                                if data.rewards.contains(title) {
                                    data.rewards.remove(title)
                                } else {
                                    data.rewards.insert(title)
                                }
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
                SuivantButton(isEnabled: !data.rewards.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingRewardView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
