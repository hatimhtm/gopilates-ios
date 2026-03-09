import SwiftUI

struct OnboardingBodyZoneView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    private let zones = ["Corps en entier", "Bras", "Abdos", "Fesse et jambes"]
    @State private var appear = false

    var body: some View {
        OnboardingScreenLayout(step: 4, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Choisissez votre domaine\nde concentration")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)

                Spacer().frame(height: 16)

                // Body silhouette with tappable zones
                HStack(alignment: .center, spacing: 24) {
                    // Left labels
                    VStack(alignment: .trailing, spacing: 32) {
                        zoneLabel("Bras", alignment: .trailing)
                            .opacity(appear ? 1 : 0)
                            .offset(x: appear ? 0 : -20)
                        Spacer()
                        zoneLabel("Fesse et jambes", alignment: .trailing)
                            .opacity(appear ? 1 : 0)
                            .offset(x: appear ? 0 : -20)
                    }
                    .frame(width: 90)

                    // Body silhouette — premium feminine version
                    FeminineBodySilhouette(selectedZones: data.focusAreas)
                        .frame(width: 100, height: 280)
                        .scaleEffect(appear ? 1 : 0.8)
                        .opacity(appear ? 1 : 0)

                    // Right labels
                    VStack(alignment: .leading, spacing: 32) {
                        zoneLabel("Corps en entier", alignment: .leading)
                            .opacity(appear ? 1 : 0)
                            .offset(x: appear ? 0 : 20)
                        Spacer()
                        zoneLabel("Abdos", alignment: .leading)
                            .opacity(appear ? 1 : 0)
                            .offset(x: appear ? 0 : 20)
                    }
                    .frame(width: 90)
                }
                .frame(height: 280)
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                // Zone selection chips — staggered entrance
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(zones.enumerated()), id: \.offset) { index, zone in
                        ZoneChip(
                            title: zone,
                            icon: zoneIcon(zone),
                            isSelected: data.focusAreas.contains(zone)
                        ) {
                            HapticManager.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if zone == "Corps en entier" {
                                    if data.focusAreas.contains(zone) {
                                        data.focusAreas.remove(zone)
                                    } else {
                                        data.focusAreas = [zone]
                                    }
                                } else {
                                    data.focusAreas.remove("Corps en entier")
                                    if data.focusAreas.contains(zone) {
                                        data.focusAreas.remove(zone)
                                    } else {
                                        data.focusAreas.insert(zone)
                                    }
                                }
                            }
                        }
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(0.3 + Double(index) * 0.08),
                            value: appear
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                SuivantButton(isEnabled: !data.focusAreas.isEmpty, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }

    private func zoneLabel(_ text: String, alignment: HorizontalAlignment) -> some View {
        let isSelected = data.focusAreas.contains(text)
        return Text(text)
            .font(.system(size: 13, weight: isSelected ? .bold : .regular))
            .foregroundColor(isSelected ? Color.vintagePink : Color.deepCharcoal.opacity(0.5))
            .multilineTextAlignment(alignment == .trailing ? .trailing : .leading)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func zoneIcon(_ zone: String) -> String {
        switch zone {
        case "Corps en entier": return "figure.pilates"
        case "Bras": return "figure.arms.open"
        case "Abdos": return "figure.core.training"
        case "Fesse et jambes": return "figure.walk"
        default: return "figure.pilates"
        }
    }
}

// MARK: - Premium Abstract Body Silhouette

struct FeminineBodySilhouette: View {
    let selectedZones: Set<String>

    private var allSelected: Bool { selectedZones.contains("Corps en entier") }
    private var armsSelected: Bool { allSelected || selectedZones.contains("Bras") }
    private var abdosSelected: Bool { allSelected || selectedZones.contains("Abdos") }
    private var legsSelected: Bool { allSelected || selectedZones.contains("Fesse et jambes") }

    var body: some View {
        ZStack {
            // Elegant abstract base figure
            Image(systemName: "figure.stand")
                .resizable()
                .scaledToFit()
                .font(Font.title.weight(.ultraLight))
                .foregroundColor(Color.deepCharcoal.opacity(0.12))
                .frame(height: 280)

            Group {
                // Full Body Aura
                if allSelected {
                    Ellipse()
                        .fill(LinearGradient(colors: [Color.vintagePink.opacity(0.6), Color.metallicGold.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 270)
                        .blur(radius: 20)
                } else {
                    // Arms Glow
                    if armsSelected {
                        Ellipse()
                            .fill(Color.vintagePink.opacity(0.6))
                            .frame(width: 100, height: 40)
                            .blur(radius: 14)
                            .offset(y: -55)
                    }

                    // Core Glow
                    if abdosSelected {
                        Ellipse()
                            .fill(Color.metallicGold.opacity(0.6))
                            .frame(width: 60, height: 75)
                            .blur(radius: 16)
                            .offset(y: 0)
                    }

                    // Legs Glow
                    if legsSelected {
                        Ellipse()
                            .fill(Color.vintagePink.opacity(0.6))
                            .frame(width: 75, height: 120)
                            .blur(radius: 18)
                            .offset(y: 85)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: selectedZones)
    }
}

// MARK: - Zone Chip (with staggered animation + icon)

struct ZoneChip: View {
    let title: String
    var icon: String = "circle"
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .vintagePink)

                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .deepCharcoal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.vintagePink : Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.vintagePink : Color.nudeModern.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color.vintagePink.opacity(0.25) : .clear, radius: 10, y: 5)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    OnboardingBodyZoneView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
