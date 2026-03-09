import SwiftUI

struct OnboardingCurrentWeightView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var useKg = true

    private var weightValues: [Double] {
        stride(from: 30.0, through: 200.0, by: 0.5).map { $0 }
    }

    private var displayValue: String {
        if useKg {
            return String(format: "%.1f", data.currentWeightKg)
        } else {
            let lbs = data.currentWeightKg * 2.20462
            return String(format: "%.0f", lbs)
        }
    }

    private var unitLabel: String {
        useKg ? "kg" : "lbs"
    }

    // Direct computed binding: writes to data.currentWeightKg immediately as picker changes
    private var pickerBinding: Binding<Int?> {
        Binding(
            get: {
                weightValues.firstIndex(where: { abs($0 - data.currentWeightKg) < 0.01 }) ?? 0
            },
            set: { newIdx in
                guard let idx = newIdx, idx >= 0, idx < weightValues.count else { return }
                data.currentWeightKg = weightValues[idx]
            }
        )
    }

    var body: some View {
        OnboardingScreenLayout(step: 6, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel est votre\npoids actuel ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 16)

                // Unit toggle
                HStack(spacing: 0) {
                    unitToggle("kg", isActive: useKg) { useKg = true }
                    unitToggle("lbs", isActive: !useKg) { useKg = false }
                }
                .background(Capsule().fill(Color.white.opacity(0.5)))
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Live number display — updates in real-time as wheel spins
                AnimatedNumberDisplay(
                    value: displayValue,
                    unit: unitLabel,
                    fontSize: 72
                )

                // Continuous wheel picker
                Picker("Poids", selection: pickerBinding) {
                    ForEach(0..<weightValues.count, id: \.self) { idx in
                        let valStr = useKg ? String(format: "%.1f", weightValues[idx]) : String(format: "%.0f", weightValues[idx] * 2.20462)
                        Text(valStr).tag(idx as Int?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: data.currentWeightKg) {
                    HapticManager.selection()
                }

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }

    private func unitToggle(_ label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isActive ? .white : .deepCharcoal.opacity(0.6))
                .frame(width: 60, height: 36)
                .background(Capsule().fill(isActive ? Color.deepCharcoal : Color.clear))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    OnboardingCurrentWeightView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
