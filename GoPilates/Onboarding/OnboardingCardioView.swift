import SwiftUI

struct OnboardingCardioView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let options: [(String, String)] = [
        ("wind", "Tres essoufflee"),
        ("lungs.fill", "Legerement essoufflee"),
        ("checkmark.seal.fill", "Completement a l'aise")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 24, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Comment vous sentez-vous\napres une marche rapide ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 16)

                Image(systemName: "figure.walk")
                    .font(.system(size: 56))
                    .foregroundColor(.vintagePink)
                    .frame(height: 80)

                Spacer().frame(height: 20)

                VStack(spacing: 12) {
                    ForEach(options, id: \.1) { icon, title in
                        OnboardingOptionCard(
                            title: title,
                            icon: icon,
                            isSelected: data.cardioFitness == title
                        ) {
                            data.cardioFitness = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.cardioFitness.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingCardioView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
