import SwiftUI

struct OnboardingInjuriesView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let injuries = ["Genou", "Bas du dos", "Épaule", "Cheville", "Cou", "Hanche"]
    @State private var appear = false

    var body: some View {
        OnboardingScreenLayout(step: 17, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Des zones blessees\nnecessitant de l'attention ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer().frame(height: 20)

                // Simple body outline
                InjuryBodyOutline()
                    .frame(height: 160)
                    .padding(.horizontal, 60)

                Spacer().frame(height: 20)

                // Injury chips
                VStack(spacing: 12) {
                    // "None" option
                    InjuryChip(
                        title: "Aucune blessure",
                        icon: "checkmark.shield.fill",
                        isSelected: data.injuries.contains("Aucune blessure")
                    ) {
                        HapticManager.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            data.injuries = ["Aucune blessure"]
                        }
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appear)

                    // Grid of injury areas with staggered entrance
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(Array(injuries.enumerated()), id: \.offset) { index, injury in
                            InjuryChip(
                                title: injury,
                                icon: injuryIcon(injury),
                                isSelected: data.injuries.contains(injury)
                            ) {
                                HapticManager.selection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    data.injuries.remove("Aucune blessure")
                                    if data.injuries.contains(injury) {
                                        data.injuries.remove(injury)
                                    } else {
                                        data.injuries.insert(injury)
                                    }
                                }
                            }
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(0.3 + Double(index) * 0.06),
                                value: appear
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.injuries.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation { appear = true }
        }
    }

    private func injuryIcon(_ injury: String) -> String {
        switch injury {
        case "Genou": return "bandage"
        case "Bas du dos": return "figure.walk"
        case "Épaule": return "figure.arms.open"
        case "Cheville": return "shoeprints.fill"
        case "Cou": return "person.bust"
        case "Hanche": return "figure.pilates"
        default: return "cross.circle"
        }
    }
}

// MARK: - Safe Body Icon for Injuries

struct InjuryBodyOutline: View {
    var body: some View {
        Image(systemName: "figure.arms.open")
            .font(.system(size: 140, weight: .light))
            .foregroundColor(.vintagePink)
            .shadow(color: .vintagePink.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Injury Chip

struct InjuryChip: View {
    let title: String
    var icon: String = "cross.circle"
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : .vintagePink)
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .deepCharcoal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 10)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.vintagePink : Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.vintagePink : Color.nudeModern.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color.vintagePink.opacity(0.25) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    OnboardingInjuriesView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
