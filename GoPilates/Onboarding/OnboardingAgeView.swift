import SwiftUI

struct OnboardingAgeView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        OnboardingScreenLayout(step: 12, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel âge as-tu ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 40)

                // Animated number display — bounces as wheel spins
                AnimatedNumberDisplay(
                    value: "\(data.age)",
                    unit: "ans",
                    fontSize: 72
                )

                // Wheel picker
                Picker("Age", selection: $data.age) {
                    ForEach(18...80, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: data.age) {
                    HapticManager.selection()
                }

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingAgeView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
