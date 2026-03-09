import SwiftUI

struct OnboardingFuturePacingView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var animateGraph = false
    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 8, onBack: onBack) {
            VStack(spacing: 0) {
                Spacer().frame(height: 24)

                // Headline
                VStack(spacing: 8) {
                    Text("\(data.targetWeightKg > data.currentWeightKg ? "Gagner" : "Perdre") \(String(format: "%.1f", data.weightDelta))kg")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                    + Text(" est possible.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.deepCharcoal)

                    Text("Realise-le !")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.metallicGold)
                }
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 40)

                // Weight curve graph
                WeightCurveGraph(
                    currentWeight: data.currentWeightKg,
                    targetWeight: data.targetWeightKg,
                    targetDateString: data.targetDateString,
                    animated: animateGraph
                )
                .frame(height: 220)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 24)

                // Motivational text
                Text("Des exercices changeront votre vie en seulement 12 semaines grace a un programme personnalise.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.5).delay(0.4)) {
                animateGraph = true
            }
        }
    }
}

// MARK: - Weight Curve Graph

struct WeightCurveGraph: View {
    let currentWeight: Double
    let targetWeight: Double
    let targetDateString: String
    let animated: Bool

    private var isGainingWeight: Bool {
        targetWeight > currentWeight
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let graphInset: CGFloat = 48
            let graphWidth = w - graphInset * 2
            let graphHeight = h - 60

            ZStack(alignment: .topLeading) {
                // Gradient fill under curve
                WeightCurveFill(progress: animated ? 1.0 : 0.0, isGainingWeight: isGainingWeight)
                    .fill(
                        LinearGradient(
                            colors: [Color.vintagePink.opacity(0.4), Color.vintagePink.opacity(0.05)],
                            startPoint: isGainingWeight ? .bottom : .top,
                            endPoint: isGainingWeight ? .top : .bottom
                        )
                    )
                    .frame(width: graphWidth, height: graphHeight)
                    .offset(x: graphInset, y: 10)

                // Curve line
                WeightCurveLine(isGainingWeight: isGainingWeight)
                    .trim(from: 0, to: animated ? 1.0 : 0.0)
                    .stroke(
                        LinearGradient(
                            colors: [Color.vintagePink, Color.metallicGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: graphWidth, height: graphHeight)
                    .offset(x: graphInset, y: 10)

                // Start dot
                Circle()
                    .fill(Color.vintagePink)
                    .frame(width: 10, height: 10)
                    .offset(x: graphInset - 5, y: (isGainingWeight ? graphHeight + 10 : 10) - 5)
                    .opacity(animated ? 1 : 0)

                // End dot (gold)
                Circle()
                    .fill(Color.metallicGold)
                    .frame(width: 12, height: 12)
                    .shadow(color: Color.metallicGold.opacity(0.5), radius: 6)
                    .offset(x: graphInset + graphWidth - 6, y: (isGainingWeight ? 10 : graphHeight + 4) - 6)
                    .opacity(animated ? 1 : 0)

                // Left label: current weight
                Text(String(format: "%.1fkg", currentWeight))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .offset(x: 0, y: isGainingWeight ? graphHeight + 4 : -4)

                // Right label: target weight
                Text(String(format: "%.1fkg", targetWeight))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.metallicGold)
                    .offset(x: w - 50, y: isGainingWeight ? -4 : graphHeight + 10)

                // Date label
                Text(targetDateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
                    .offset(x: w - 55, y: h - 16)

                // "Aujourd'hui" label
                Text("Aujourd'hui")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.4))
                    .offset(x: graphInset - 10, y: h - 16)
            }
        }
    }
}

// MARK: - Curve Shape (line only)

struct WeightCurveLine: Shape {
    let isGainingWeight: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startY = isGainingWeight ? rect.height : 0
        let endY = isGainingWeight ? 0 : rect.height
        let cp1Y = isGainingWeight ? rect.height * 0.85 : rect.height * 0.15
        let cp2Y = isGainingWeight ? rect.height * 0.15 : rect.height * 0.85
        let startPoint = CGPoint(x: 0, y: startY)
        let endPoint = CGPoint(x: rect.width, y: endY)
        let control1 = CGPoint(x: rect.width * 0.3, y: cp1Y)
        let control2 = CGPoint(x: rect.width * 0.65, y: cp2Y)

        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: control1, control2: control2)
        return path
    }
}

// MARK: - Curve Shape (filled area)

struct WeightCurveFill: Shape {
    var progress: CGFloat
    let isGainingWeight: Bool

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let endX = rect.width * progress
        let endY = isGainingWeight 
            ? rect.height - (rect.height * progress) 
            : rect.height * progress

        let cp1Y = isGainingWeight 
            ? rect.height - (rect.height * 0.15 * progress) 
            : rect.height * 0.15 * progress

        let cp2Y = isGainingWeight 
            ? rect.height - (rect.height * 0.85 * progress) 
            : rect.height * 0.85 * progress

        let startY = isGainingWeight ? rect.height : 0

        path.move(to: CGPoint(x: 0, y: startY))
        path.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: rect.width * 0.3 * progress, y: cp1Y),
            control2: CGPoint(x: rect.width * 0.65 * progress, y: cp2Y)
        )
        path.addLine(to: CGPoint(x: endX, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    OnboardingFuturePacingView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
