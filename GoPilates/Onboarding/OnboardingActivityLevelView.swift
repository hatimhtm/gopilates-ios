import SwiftUI

struct OnboardingActivityLevelView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let levels: [(String, String, String)] = [
        ("sofa.fill", "Inactive", "Peu ou pas d'exercice regulier"),
        ("figure.walk", "Legerement active", "Exercice leger 1-3 fois/semaine"),
        ("figure.run", "Tres active", "Exercice intense 4-5 fois/semaine")
    ]

    var body: some View {
        OnboardingScreenLayout(step: 20, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Choisissez votre\nniveau d'activite")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 24)

                VStack(spacing: 14) {
                    ForEach(levels, id: \.1) { icon, title, desc in
                        ActivityLevelCard(
                            icon: icon,
                            title: title,
                            description: desc,
                            isSelected: data.activityLevel == title
                        ) {
                            HapticManager.selection()
                            data.activityLevel = title
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.activityLevel.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct ActivityLevelCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 36 : 28))
                    .foregroundColor(isSelected ? Color.vintagePink : Color.deepCharcoal.opacity(0.4))
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepCharcoal)

                    if isSelected {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.vintagePink)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.vintagePink : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    OnboardingActivityLevelView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
