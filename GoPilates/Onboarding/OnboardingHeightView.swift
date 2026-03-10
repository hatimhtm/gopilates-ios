import SwiftUI

struct OnboardingHeightView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var useCm = true

    private var displayValue: String {
        if useCm {
            return "\(data.heightCm)"
        } else {
            let totalInches = Double(data.heightCm) / 2.54
            let feet = Int(totalInches) / 12
            let inches = Int(totalInches) % 12
            return "\(feet)'\(inches)\""
        }
    }

    var body: some View {
        @Bindable var data = data
        return OnboardingScreenLayout(step: 5, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quelle taille\nfaites-vous ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 16)

                // Unit toggle
                HStack(spacing: 0) {
                    unitToggle("cm", isActive: useCm) { useCm = true }
                    unitToggle("ft", isActive: !useCm) { useCm = false }
                }
                .background(
                    Capsule().fill(Color.white.opacity(0.5))
                )
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                // Animated number display — bounces as wheel spins
                AnimatedNumberDisplay(
                    value: displayValue,
                    unit: useCm ? "cm" : "",
                    fontSize: 72
                )

                // Wheel picker
                Picker("Taille", selection: $data.heightCm) {
                    ForEach(140...210, id: \.self) { h in
                        Text("\(h)").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: data.heightCm) {
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
                .background(
                    Capsule().fill(isActive ? Color.deepCharcoal : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    OnboardingHeightView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
