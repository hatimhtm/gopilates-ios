import SwiftUI

struct OnboardingBodyTypeTargetView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var sliderValue: Double = 0.0
    @State private var appear = false

    private let typeLabels = ["Mince", "Légère", "Moyenne", "Ample"]
    private let fatRanges = ["15-20%", "20-25%", "25-30%", "30%+"]

    private var currentLabel: String {
        let idx = Int(sliderValue.rounded())
        return typeLabels[min(max(idx, 0), typeLabels.count - 1)]
    }

    private var currentFat: String {
        let idx = Int(sliderValue.rounded())
        return fatRanges[min(max(idx, 0), fatRanges.count - 1)]
    }

    /// FIXED: 0 = Mince (thin, narrow), 3 = Ample (wide, curvy)
    private var widthFactor: CGFloat {
        let t = CGFloat(sliderValue / 3.0)
        return 0.55 + t * 0.45
    }

    var body: some View {
        OnboardingScreenLayout(step: 10, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Quel type de corps\nsouhaitez-vous ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)

                Spacer().frame(height: 16)

                ZStack {
                    Ellipse()
                        .fill(Color.metallicGold.opacity(0.08))
                        .frame(width: 160, height: 300)
                        .blur(radius: 25)

                    Image(systemName: "figure.stand")
                        .font(.system(size: 160, weight: .ultraLight))
                        .foregroundColor(Color.metallicGold.opacity(0.7))
                        .scaleEffect(x: widthFactor, y: 1.0)
                        .animation(.easeInOut(duration: 0.3), value: widthFactor)
                }
                .frame(height: 260)
                .scaleEffect(appear ? 1 : 0.7)
                .opacity(appear ? 1 : 0)

                Spacer().frame(height: 12)

                VStack(spacing: 4) {
                    Text(currentLabel)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.deepCharcoal)

                    Text("Objectif masse grasse : \(currentFat)")
                        .font(.system(size: 14))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                }
                .animation(.easeInOut(duration: 0.2), value: sliderValue)

                Spacer().frame(height: 20)

                VStack(spacing: 12) {
                    HStack {
                        ForEach(typeLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.deepCharcoal.opacity(0.4))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 24)

                    Slider(value: $sliderValue, in: 0...3)
                        .tint(Color.metallicGold)
                        .padding(.horizontal, 24)
                        .onChange(of: sliderValue) { _, newValue in
                            let rounded = Int(newValue.rounded())
                            if rounded != data.targetBodyType {
                                HapticManager.selection()
                                data.targetBodyType = rounded
                            }
                        }
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
            }
        }
        .onAppear {
            sliderValue = Double(data.targetBodyType)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

#Preview {
    OnboardingBodyTypeTargetView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
