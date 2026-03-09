import SwiftUI

struct OnboardingWeightProjectionView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var animateGraph = false
    @State private var showContent = false

    var body: some View {
        OnboardingScreenLayout(step: 11, onBack: onBack) {
            VStack(spacing: 0) {
                // Title
                Text("Votre objectif estimé : ")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.deepCharcoal)
                + Text(data.projectedWeightString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.metallicGold)
                + Text(" aux alentours de ")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.deepCharcoal)
                + Text(data.targetDateString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.metallicGold)

                Spacer().frame(height: 24)

                // Detailed projection graph
                ProjectionGraph(
                    currentWeight: data.currentWeightKg,
                    targetWeight: data.targetWeightKg,
                    animated: animateGraph
                )
                .frame(height: 240)
                .padding(.horizontal, 16)

                Spacer().frame(height: 24)

                // BMI info card
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("Votre IMC")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                        Text(String(format: "%.1f", data.bmi))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.deepCharcoal)
                    }

                    Rectangle()
                        .fill(Color.nudeModern.opacity(0.5))
                        .frame(width: 1, height: 40)

                    VStack(spacing: 4) {
                        Text("Categorie")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                        Text(data.bmiCategory)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.deepCharcoal)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Text("* Estimation basée sur votre profil. Les résultats varient selon chaque personne.")
                    .font(.system(size: 11))
                    .foregroundColor(.deepCharcoal.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .padding(.top, 12)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.8).delay(0.3)) {
                animateGraph = true
            }
        }
    }
}

// MARK: - Projection Graph with Milestones

struct ProjectionGraph: View {
    let currentWeight: Double
    let targetWeight: Double
    let animated: Bool

    private var isGainingWeight: Bool {
        targetWeight > currentWeight
    }

    private var milestones: [(CGFloat, String)] {
        // 6 milestone points across 12 weeks
        let delta = currentWeight - targetWeight
        return [
            (0.0, String(format: "%.1f", currentWeight)),
            (0.17, String(format: "%.1f", currentWeight - delta * 0.12)),
            (0.33, String(format: "%.1f", currentWeight - delta * 0.28)),
            (0.50, String(format: "%.1f", currentWeight - delta * 0.48)),
            (0.67, String(format: "%.1f", currentWeight - delta * 0.68)),
            (0.83, String(format: "%.1f", currentWeight - delta * 0.85)),
            (1.0, String(format: "%.1f", targetWeight))
        ]
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let insetX: CGFloat = 40
            let insetTop: CGFloat = 20
            let insetBottom: CGFloat = 30
            let graphW = w - insetX * 2
            let graphH = h - insetTop - insetBottom

            ZStack(alignment: .topLeading) {
                // Horizontal grid lines
                ForEach(0..<4, id: \.self) { i in
                    let y = insetTop + graphH * CGFloat(i) / 3.0
                    Path { p in
                        p.move(to: CGPoint(x: insetX, y: y))
                        p.addLine(to: CGPoint(x: w - insetX, y: y))
                    }
                    .stroke(Color.nudeModern.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                // Gradient fill under curve
                ProjectionCurveFill(progress: animated ? 1.0 : 0.0, isGainingWeight: isGainingWeight)
                    .fill(
                        LinearGradient(
                            colors: [Color.vintagePink.opacity(0.3), Color.champagneBlush.opacity(0.05)],
                            startPoint: isGainingWeight ? .bottom : .top,
                            endPoint: isGainingWeight ? .top : .bottom
                        )
                    )
                    .frame(width: graphW, height: graphH)
                    .offset(x: insetX, y: insetTop)

                // Curve line
                ProjectionCurvePath(isGainingWeight: isGainingWeight)
                    .trim(from: 0, to: animated ? 1.0 : 0.0)
                    .stroke(
                        LinearGradient(
                            colors: [Color.vintagePink, Color.metallicGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: graphW, height: graphH)
                    .offset(x: insetX, y: insetTop)

                // Milestone dots
                if animated {
                    ForEach(0..<milestones.count, id: \.self) { i in
                        let pt = curvePoint(at: milestones[i].0, in: CGSize(width: graphW, height: graphH), isGainingWeight: isGainingWeight)
                        let isLast = i == milestones.count - 1

                        Circle()
                            .fill(isLast ? Color.metallicGold : Color.white)
                            .frame(width: isLast ? 12 : 8, height: isLast ? 12 : 8)
                            .overlay(
                                Circle()
                                    .stroke(isLast ? Color.metallicGold : Color.vintagePink, lineWidth: 2)
                            )
                            .shadow(color: isLast ? Color.metallicGold.opacity(0.4) : .clear, radius: 4)
                            .offset(
                                x: insetX + pt.x - (isLast ? 6 : 4),
                                y: insetTop + pt.y - (isLast ? 6 : 4)
                            )
                            .transition(.scale)
                    }
                }

                // Weight labels on left
                Text(String(format: "%.0f", currentWeight))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
                    .offset(x: 4, y: isGainingWeight ? insetTop + graphH - 6 : insetTop - 6)

                Text(String(format: "%.0f", targetWeight))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.metallicGold)
                    .offset(x: 4, y: isGainingWeight ? insetTop - 6 : insetTop + graphH - 6)

                // Week labels at bottom
                ForEach([0, 4, 8, 12], id: \.self) { week in
                    let x = insetX + graphW * CGFloat(week) / 12.0
                    Text("S\(week)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.deepCharcoal.opacity(0.4))
                        .offset(x: x - 8, y: h - 14)
                }
            }
        }
    }

    private func curvePoint(at t: CGFloat, in size: CGSize, isGainingWeight: Bool) -> CGPoint {
        // Bezier curve matching the projection path
        let p0 = isGainingWeight ? CGPoint(x: 0, y: size.height) : CGPoint(x: 0, y: 0)
        let p1 = isGainingWeight ? CGPoint(x: size.width * 0.25, y: size.height * 0.9) : CGPoint(x: size.width * 0.25, y: size.height * 0.1)
        let p2 = isGainingWeight ? CGPoint(x: size.width * 0.7, y: size.height * 0.2) : CGPoint(x: size.width * 0.7, y: size.height * 0.8)
        let p3 = isGainingWeight ? CGPoint(x: size.width, y: 0) : CGPoint(x: size.width, y: size.height)
        let mt = 1 - t
        let x = mt*mt*mt*p0.x + 3*mt*mt*t*p1.x + 3*mt*t*t*p2.x + t*t*t*p3.x
        let y = mt*mt*mt*p0.y + 3*mt*mt*t*p1.y + 3*mt*t*t*p2.y + t*t*t*p3.y
        return CGPoint(x: x, y: y)
    }
}

struct ProjectionCurvePath: Shape {
    let isGainingWeight: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startY = isGainingWeight ? rect.height : 0
        let endY = isGainingWeight ? 0 : rect.height
        let cp1Y = isGainingWeight ? rect.height * 0.9 : rect.height * 0.1
        let cp2Y = isGainingWeight ? rect.height * 0.2 : rect.height * 0.8
        
        path.move(to: CGPoint(x: 0, y: startY))
        path.addCurve(
            to: CGPoint(x: rect.width, y: endY),
            control1: CGPoint(x: rect.width * 0.25, y: cp1Y),
            control2: CGPoint(x: rect.width * 0.7, y: cp2Y)
        )
        return path
    }
}

struct ProjectionCurveFill: Shape {
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
            ? rect.height - (rect.height * 0.1 * progress) 
            : rect.height * 0.1 * progress

        let cp2Y = isGainingWeight 
            ? rect.height - (rect.height * 0.8 * progress) 
            : rect.height * 0.8 * progress

        let startY = isGainingWeight ? rect.height : 0

        path.move(to: CGPoint(x: 0, y: startY))
        path.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: rect.width * 0.25 * progress, y: cp1Y),
            control2: CGPoint(x: rect.width * 0.7 * progress, y: cp2Y)
        )
        path.addLine(to: CGPoint(x: endX, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    OnboardingWeightProjectionView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
