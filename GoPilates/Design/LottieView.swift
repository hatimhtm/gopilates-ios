import SwiftUI

// MARK: - Pilates Pose Animation View
// Replaces Lottie dependency with a rich SwiftUI-native animated pilates figure system.

struct PilatesAnimatedFigure: View {
    let category: ExerciseCategory
    var size: CGFloat = 120
    @State private var breathe = false
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(figureColor.opacity(breathe ? 0.15 : 0.05), lineWidth: size * 0.1)
                .frame(width: size * 1.4, height: size * 1.4)
                .scaleEffect(breathe ? 1.08 : 0.95)

            // Inner gradient disc
            Circle()
                .fill(
                    RadialGradient(
                        colors: [figureColor.opacity(0.18), figureColor.opacity(0.04)],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.1, height: size * 1.1)

            // Category-specific pose illustration
            poseView
                .frame(width: size, height: size)
                .scaleEffect(breathe ? 1.04 : 0.97)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }

    @ViewBuilder
    private var poseView: some View {
        switch category {
        case .coreIntegration:
            CorePoseView(color: figureColor, breathe: breathe, size: size)
        case .lowerBody:
            BridgePoseView(color: figureColor, breathe: breathe, size: size)
        case .upperBody:
            ArmsPoseView(color: figureColor, breathe: breathe, size: size)
        case .fullBody:
            PlankPoseView(color: figureColor, breathe: breathe, size: size)
        case .classical:
            HundredPoseView(color: figureColor, breathe: breathe, size: size)
        case .restorative:
            StretchPoseView(color: figureColor, breathe: breathe, size: size)
        }
    }

    private var figureColor: Color {
        switch category {
        case .coreIntegration: return Color(hex: "E8B6C3")
        case .lowerBody:       return Color(hex: "DDB263")
        case .upperBody:       return Color(hex: "7B9EBC")
        case .fullBody:        return Color(hex: "A0C4A8")
        case .classical:       return Color(hex: "D4A0C4")
        case .restorative:     return Color(hex: "B8C8D8")
        }
    }
}

// MARK: - Core Pose (Dead Bug / Hundred position)
struct CorePoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0

            // Head
            ctx.stroke(Path { p in
                p.addEllipse(in: CGRect(x: cx - 9*s, y: cy - 40*s, width: 18*s, height: 18*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Torso (lying down)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy - 22*s))
                p.addLine(to: CGPoint(x: cx, y: cy + 10*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Knees bent up (dead bug position)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy + 10*s))
                p.addLine(to: CGPoint(x: cx - 18*s, y: cy + 2*s))
                p.addLine(to: CGPoint(x: cx - 18*s, y: cy - 14*s))
            }, with: .color(color), lineWidth: 2*s)

            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy + 10*s))
                p.addLine(to: CGPoint(x: cx + 18*s, y: cy + 2*s))
                p.addLine(to: CGPoint(x: cx + 18*s, y: cy - 14*s))
            }, with: .color(color), lineWidth: 2*s)

            // Arms raised
            ctx.stroke(Path { p in
                let lift: CGFloat = breathe ? -4*s : 0
                p.move(to: CGPoint(x: cx, y: cy - 22*s))
                p.addLine(to: CGPoint(x: cx - 22*s, y: cy - 38*s + lift))
            }, with: .color(color), lineWidth: 2*s)
            ctx.stroke(Path { p in
                let lift: CGFloat = breathe ? -4*s : 0
                p.move(to: CGPoint(x: cx, y: cy - 22*s))
                p.addLine(to: CGPoint(x: cx + 22*s, y: cy - 38*s + lift))
            }, with: .color(color), lineWidth: 2*s)
        }
    }
}

// MARK: - Bridge Pose (Glute Bridge)
struct BridgePoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0
            let lift: CGFloat = breathe ? 8*s : 4*s

            // Head on ground
            ctx.stroke(Path { p in
                p.addEllipse(in: CGRect(x: cx - 36*s, y: cy + 10*s, width: 16*s, height: 16*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Torso lifted
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 28*s, y: cy + 10*s))
                p.addCurve(
                    to: CGPoint(x: cx + 10*s, y: cy - 10*s - lift),
                    control1: CGPoint(x: cx - 10*s, y: cy - lift),
                    control2: CGPoint(x: cx, y: cy - 14*s - lift)
                )
            }, with: .color(color), lineWidth: 2.5*s)

            // Thighs
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx + 10*s, y: cy - 10*s - lift))
                p.addLine(to: CGPoint(x: cx + 22*s, y: cy + 14*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Calves flat
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx + 22*s, y: cy + 14*s))
                p.addLine(to: CGPoint(x: cx + 38*s, y: cy + 18*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Arms flat on floor
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 28*s, y: cy + 16*s))
                p.addLine(to: CGPoint(x: cx - 42*s, y: cy + 22*s))
            }, with: .color(color), lineWidth: 2*s)

            // Ground line
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 50*s, y: cy + 26*s))
                p.addLine(to: CGPoint(x: cx + 50*s, y: cy + 26*s))
            }, with: .color(color.opacity(0.3)), lineWidth: 1.5*s)
        }
    }
}

// MARK: - Arms / Upper Body (Wall Push-Up style)
struct ArmsPoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0
            let reach: CGFloat = breathe ? 2*s : -2*s

            // Head
            ctx.stroke(Path { p in
                p.addEllipse(in: CGRect(x: cx - 8*s, y: cy - 40*s, width: 16*s, height: 16*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Torso
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy - 24*s))
                p.addLine(to: CGPoint(x: cx, y: cy + 12*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Arms extended outward
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy - 18*s))
                p.addLine(to: CGPoint(x: cx - 36*s + reach, y: cy - 8*s))
            }, with: .color(color), lineWidth: 2.5*s)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy - 18*s))
                p.addLine(to: CGPoint(x: cx + 36*s - reach, y: cy - 8*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Legs standing
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy + 12*s))
                p.addLine(to: CGPoint(x: cx - 8*s, y: cy + 38*s))
            }, with: .color(color), lineWidth: 2.5*s)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx, y: cy + 12*s))
                p.addLine(to: CGPoint(x: cx + 8*s, y: cy + 38*s))
            }, with: .color(color), lineWidth: 2.5*s)
        }
    }
}

// MARK: - Plank Pose (Full Body)
struct PlankPoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0
            let tension: CGFloat = breathe ? -2*s : 0

            // Head
            ctx.stroke(Path { p in
                p.addEllipse(in: CGRect(x: cx - 40*s, y: cy - 6*s + tension, width: 14*s, height: 14*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Body line (plank - diagonal)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 26*s, y: cy + 4*s + tension))
                p.addLine(to: CGPoint(x: cx + 34*s, y: cy + 20*s + tension))
            }, with: .color(color), lineWidth: 3*s)

            // Forearm support
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 26*s, y: cy + 4*s + tension))
                p.addLine(to: CGPoint(x: cx - 16*s, y: cy + 20*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Foot
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx + 34*s, y: cy + 20*s + tension))
                p.addLine(to: CGPoint(x: cx + 44*s, y: cy + 22*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Ground line
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 50*s, y: cy + 24*s))
                p.addLine(to: CGPoint(x: cx + 50*s, y: cy + 24*s))
            }, with: .color(color.opacity(0.3)), lineWidth: 1.5*s)
        }
    }
}

// MARK: - Hundred Pose (Classical)
struct HundredPoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0
            let pump: CGFloat = breathe ? -5*s : 0

            // Head raised off ground
            ctx.stroke(Path { p in
                p.addEllipse(in: CGRect(x: cx - 40*s, y: cy - 30*s, width: 14*s, height: 14*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Torso curled
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 26*s, y: cy - 20*s))
                p.addLine(to: CGPoint(x: cx + 4*s, y: cy + 4*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Legs extended at 45°
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx + 4*s, y: cy + 4*s))
                p.addLine(to: CGPoint(x: cx + 44*s, y: cy - 20*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Arms pumping
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 14*s, y: cy - 8*s))
                p.addLine(to: CGPoint(x: cx + 30*s, y: cy + pump))
            }, with: .color(color), lineWidth: 2*s)

            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 14*s, y: cy - 4*s))
                p.addLine(to: CGPoint(x: cx + 30*s, y: cy + 4*s + pump))
            }, with: .color(color), lineWidth: 2*s)
        }
    }
}

// MARK: - Stretch Pose (Restorative / Cat-Cow)
struct StretchPoseView: View {
    let color: Color
    let breathe: Bool
    let size: CGFloat

    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w / 2, cy = h / 2
            let s = size / 120.0
            let arch: CGFloat = breathe ? -8*s : 8*s

            // Head
            ctx.stroke(Path { p in
                let headY = breathe ? cy - 4*s : cy + 4*s
                p.addEllipse(in: CGRect(x: cx - 38*s, y: headY - 7*s, width: 14*s, height: 14*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Spine curve (cat-cow arch)
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 24*s, y: cy + 4*s))
                p.addCurve(
                    to: CGPoint(x: cx + 24*s, y: cy + 4*s),
                    control1: CGPoint(x: cx - 8*s, y: cy + arch),
                    control2: CGPoint(x: cx + 8*s, y: cy + arch)
                )
            }, with: .color(color), lineWidth: 2.5*s)

            // Front arm
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 24*s, y: cy + 4*s))
                p.addLine(to: CGPoint(x: cx - 38*s, y: cy + 20*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Back leg
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx + 24*s, y: cy + 4*s))
                p.addLine(to: CGPoint(x: cx + 38*s, y: cy + 20*s))
            }, with: .color(color), lineWidth: 2.5*s)

            // Ground line
            ctx.stroke(Path { p in
                p.move(to: CGPoint(x: cx - 50*s, y: cy + 22*s))
                p.addLine(to: CGPoint(x: cx + 50*s, y: cy + 22*s))
            }, with: .color(color.opacity(0.3)), lineWidth: 1.5*s)
        }
    }
}

// MARK: - Helper function for Lottie fallback compatibility
func lottieAnimationExists(_ name: String) -> Bool {
    // We no longer use Lottie JSON files — all animations are SwiftUI-native
    return false
}

// MARK: - LottieView Compatibility Shim
// Replaces the Lottie dependency. Accepts the original API but renders a SwiftUI animation.
// loopMode is accepted but ignored — animations always loop gently for a premium feel.

enum LottieLoopMode {
    case loop
    case playOnce
    case autoReverse
    case repeatCount(Float)
}

struct LottieView: View {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: Double = 1.0

    @State private var breathe = false
    @State private var rotateAngle: Double = 0
    @State private var pulse = false
    @State private var iconScale: CGFloat = 1.0

    private var accentColor: Color {
        switch animationName {
        case let n where n.contains("greeting"):    return Color.vintagePink
        case let n where n.contains("celebration"): return Color.metallicGold
        case let n where n.contains("success"):     return Color(hex: "A0C4A8")
        case let n where n.contains("loading"):     return Color.vintagePink
        default:                                    return Color.vintagePink
        }
    }

    private var sfIcon: String {
        switch animationName {
        case let n where n.contains("greeting"):    return "figure.pilates"
        case let n where n.contains("celebration"): return "star.fill"
        case let n where n.contains("success"):     return "checkmark.seal.fill"
        case let n where n.contains("loading"):     return "figure.core.training"
        default:                                    return "sparkles"
        }
    }

    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .scaleEffect(pulse ? 1.15 : 0.9)
                .opacity(pulse ? 0.6 : 0.3)

            // Spinning arc ring
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(
                    AngularGradient(
                        colors: [accentColor.opacity(0), accentColor.opacity(0.5), accentColor.opacity(0)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(rotateAngle))

            // Inner ambient fill
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.18), accentColor.opacity(0.04)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .scaleEffect(breathe ? 1.05 : 0.95)

            // Petal accents
            ForEach(0..<6, id: \.self) { i in
                Ellipse()
                    .fill(accentColor.opacity(breathe ? 0.2 : 0.1))
                    .frame(width: 36, height: 16)
                    .offset(y: -32)
                    .rotationEffect(.degrees(Double(i) * 60 + rotateAngle * 0.15))
            }

            // Central premium SF Symbol — NO stick figure
            Image(systemName: sfIcon)
                .font(.system(size: 52, weight: .medium))
                .foregroundColor(accentColor)
                .scaleEffect(iconScale)
                .shadow(color: accentColor.opacity(0.25), radius: 8)
        }
        .onAppear {
            withAnimation(.spring(response: 3.0 / animationSpeed, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.linear(duration: 8.0 / animationSpeed).repeatForever(autoreverses: false)) {
                rotateAngle = 360
            }
            withAnimation(.spring(response: 2.0 / animationSpeed, dampingFraction: 0.5).repeatForever(autoreverses: true).delay(0.5)) {
                pulse = true
            }
            withAnimation(.spring(response: 2.5 / animationSpeed, dampingFraction: 0.5).repeatForever(autoreverses: true).delay(0.2)) {
                iconScale = 1.15
            }
        }
    }
}
