import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Brand Colors

extension Color {
    /// #FDE2DB — Main background
    static let champagneBlush = Color(hex: "FDE2DB")
    /// #E6C7B2 — Cards / secondary surfaces
    static let nudeModern = Color(hex: "E6C7B2")
    /// #E8B6C3 — Soft accent, progress bar, selection borders
    static let vintagePink = Color(hex: "E8B6C3")
    /// #DDB263 — Gold accent, final CTA buttons
    static let metallicGold = Color(hex: "DDB263")
    /// #3A2A2F — Primary text and standard CTA buttons
    static let deepCharcoal = Color(hex: "3A2A2F")
}

// MARK: - Onboarding Background

struct OnboardingBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.champagneBlush,
                Color.champagneBlush.opacity(0.95),
                Color(hex: "FFF5F0")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.nudeModern.opacity(0.3))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.vintagePink)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.35), value: current)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 24)
    }
}

// MARK: - Back Button

struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            action()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepCharcoal)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Suivant Button (Primary CTA)

struct SuivantButton: View {
    var title: String = "Suivant"
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? Color.deepCharcoal : Color.gray.opacity(0.35))
                )
                .shadow(
                    color: isEnabled ? Color.deepCharcoal.opacity(0.15) : .clear,
                    radius: 10, x: 0, y: 5
                )
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Gold CTA Button

struct GoldButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.notification(.success)
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.metallicGold)
                )
                .shadow(
                    color: Color.metallicGold.opacity(0.3),
                    radius: 15, x: 0, y: 8
                )
        }
    }
}

// MARK: - Option Card (Selection)

struct OnboardingOptionCard: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 14) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color.vintagePink : Color.deepCharcoal.opacity(0.5))
                        .frame(width: 28)
                }

                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.vintagePink)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.vintagePink : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.04) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Multi-Select Option Card

struct OnboardingMultiOptionCard: View {
    let title: String
    var icon: String? = nil
    var emoji: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 14) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 22))
                        .frame(width: 28)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color.vintagePink : Color.deepCharcoal.opacity(0.5))
                        .frame(width: 28)
                }

                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.vintagePink : Color.deepCharcoal.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.vintagePink)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.vintagePink : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.04) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Standard Onboarding Screen Layout

struct OnboardingScreenLayout<Content: View>: View {
    let step: Int
    let totalSteps: Int
    let showBack: Bool
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        step: Int,
        totalSteps: Int = 38,
        showBack: Bool = true,
        onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.step = step
        self.totalSteps = totalSteps
        self.showBack = showBack
        self.onBack = onBack
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
        }
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
