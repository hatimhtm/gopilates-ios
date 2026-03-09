import SwiftUI

struct OnboardingTargetWeightView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var pickerIndex: Int? = 60 // default 60.0kg

    private var weightValues: [Double] {
        stride(from: 30.0, through: 200.0, by: 0.5).map { $0 }
    }

    private var pickerBinding: Binding<Int?> {
        Binding(
            get: {
                weightValues.firstIndex(where: { abs($0 - data.targetWeightKg) < 0.01 }) ?? 0
            },
            set: { newIdx in
                guard let idx = newIdx, idx >= 0, idx < weightValues.count else { return }
                data.targetWeightKg = weightValues[idx]
            }
        )
    }

    var body: some View {
        OnboardingScreenLayout(step: 7, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel est votre\npoids cible ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 8)

                // Reference: current weight
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                    Text("Poids actuel : \(String(format: "%.1f", data.currentWeightKg))kg")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.deepCharcoal.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Live number display — updates in real-time as wheel spins
                AnimatedNumberDisplay(
                    value: String(format: "%.1f", data.targetWeightKg),
                    unit: "kg",
                    fontSize: 72
                )

                // Continuous wheel picker — matches current weight screen
                Picker("Poids cible", selection: pickerBinding) {
                    ForEach(0..<weightValues.count, id: \.self) { idx in
                        Text(String(format: "%.1f", weightValues[idx])).tag(idx as Int?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: data.targetWeightKg) {
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
    OnboardingTargetWeightView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
