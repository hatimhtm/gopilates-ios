import SwiftUI

// MARK: - Shared Silhouette Helpers

/// Reusable body-segment shapes for building anatomically correct silhouettes.
private struct SilhouetteHead: View {
    var color: Color = .deepCharcoal
    var body: some View {
        Ellipse()
            .fill(color)
            .frame(width: 22, height: 26)
    }
}

private struct SilhouetteTorso: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.3, y: 0))
        p.addQuadCurve(to: CGPoint(x: w * 0.25, y: h),
                       control: CGPoint(x: w * 0.15, y: h * 0.5))
        p.addLine(to: CGPoint(x: w * 0.75, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.7, y: 0),
                       control: CGPoint(x: w * 0.85, y: h * 0.5))
        p.closeSubpath()
        return p
    }
}

private struct LimbShape: Shape {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0 else { return p }
        let nx = -dy / len * thickness / 2
        let ny = dx / len * thickness / 2
        p.move(to: CGPoint(x: startPoint.x + nx, y: startPoint.y + ny))
        p.addLine(to: CGPoint(x: endPoint.x + nx * 0.6, y: endPoint.y + ny * 0.6))
        p.addLine(to: CGPoint(x: endPoint.x - nx * 0.6, y: endPoint.y - ny * 0.6))
        p.addLine(to: CGPoint(x: startPoint.x - nx, y: startPoint.y - ny))
        p.closeSubpath()
        return p
    }
}

// MARK: - 1. Pilates Breathing
struct AnimationPilatesBreathing: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            // Supine figure with chest expanding
            ZStack {
                // Mat line
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6)
                    .offset(y: 50)
                // Body lying down
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 90, height: 20)
                    .offset(y: 38)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 22, height: 22)
                    .offset(x: -58, y: 38)
                // Chest / ribcage expanding
                Ellipse().fill(Color.vintagePink.opacity(0.4))
                    .frame(width: animate ? 50 : 38, height: animate ? 28 : 20)
                    .offset(x: -15, y: 32)
                // Bent knees
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 36, height: 12)
                    .rotationEffect(.degrees(-55))
                    .offset(x: 52, y: 20)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 36, height: 12)
                    .rotationEffect(.degrees(-55))
                    .offset(x: 68, y: 20)
                // Feet flat
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 28, height: 10)
                    .offset(x: 72, y: 44)
                // Breath indicator rings
                Circle().stroke(Color.metallicGold.opacity(animate ? 0.5 : 0.0), lineWidth: 2)
                    .frame(width: animate ? 70 : 30, height: animate ? 70 : 30)
                    .offset(x: -15, y: 20)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 2. Pelvic Tilt
struct AnimationPelvicTilt: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -70, y: 42)
                // Upper back
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 18).offset(x: -38, y: 42)
                // Pelvis tilting
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 40, height: 18)
                    .rotationEffect(.degrees(animate ? -12 : 5))
                    .offset(x: 5, y: animate ? 36 : 44)
                // Highlight pelvis
                Ellipse().fill(Color.metallicGold.opacity(0.35))
                    .frame(width: 30, height: 16)
                    .offset(x: 5, y: animate ? 34 : 42)
                // Thighs bent up
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 35, height: 12)
                    .rotationEffect(.degrees(-60))
                    .offset(x: 38, y: 22)
                // Shins
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 30, height: 11)
                    .rotationEffect(.degrees(5))
                    .offset(x: 56, y: 44)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 3. Glute Bridge
struct AnimationGluteBridge: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -75, y: 50)
                // Shoulders on floor
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 35, height: 16).offset(x: -52, y: 50)
                // Torso lifting
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 18)
                    .rotationEffect(.degrees(animate ? -18 : 0))
                    .offset(x: -12, y: animate ? 38 : 48)
                // Glutes highlight
                Circle().fill(Color.metallicGold.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 24, height: 24)
                    .offset(x: 10, y: animate ? 30 : 46)
                // Thighs
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 38, height: 13)
                    .rotationEffect(.degrees(animate ? -50 : -35))
                    .offset(x: 40, y: animate ? 28 : 38)
                // Shins vertical
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 34, height: 12)
                    .rotationEffect(.degrees(animate ? 80 : 60))
                    .offset(x: 60, y: 48)
                // Feet
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 18, height: 8).offset(x: 68, y: 56)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 4. Supine Leg Lift
struct AnimationSupineLegLift: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -70, y: 45)
                // Torso flat
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 80, height: 18).offset(x: -20, y: 45)
                // Grounded leg bent
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 35, height: 12)
                    .rotationEffect(.degrees(-55)).offset(x: 40, y: 28)
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 28, height: 10).offset(x: 55, y: 48)
                // Lifting leg
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 13)
                    .rotationEffect(.degrees(animate ? -75 : -15))
                    .offset(x: 48, y: animate ? 5 : 35)
                // Quad highlight
                Capsule().fill(Color.vintagePink.opacity(0.3))
                    .frame(width: 40, height: 8)
                    .rotationEffect(.degrees(animate ? -75 : -15))
                    .offset(x: 48, y: animate ? 5 : 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 5. Cat-Cow Stretch
struct AnimationCatCowStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                // Hands on ground
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: -50, y: 55)
                // Arms
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 8, height: 40)
                    .rotationEffect(.degrees(animate ? 5 : -5))
                    .offset(x: -50, y: 35)
                // Head
                Ellipse().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 22)
                    .offset(x: -55, y: animate ? 10 : 18)
                // Spine curving - using a custom arc
                SpineCurve(curvature: animate ? -20 : 20)
                    .stroke(Color.deepCharcoal.opacity(0.85), lineWidth: 18)
                    .frame(width: 90, height: 40)
                    .offset(x: -2, y: animate ? 18 : 25)
                // Spine highlight
                SpineCurve(curvature: animate ? -20 : 20)
                    .stroke(Color.vintagePink.opacity(0.4), lineWidth: 8)
                    .frame(width: 90, height: 40)
                    .offset(x: -2, y: animate ? 18 : 25)
                // Hips
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 22, height: 22).offset(x: 45, y: 28)
                // Rear legs
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 8, height: 38)
                    .rotationEffect(.degrees(animate ? -5 : 5))
                    .offset(x: 45, y: 48)
                // Knees on ground
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: 45, y: 55)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

private struct SpineCurve: Shape {
    var curvature: CGFloat
    var animatableData: CGFloat {
        get { curvature }
        set { curvature = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.midY))
        p.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY + curvature)
        )
        return p
    }
}

// MARK: - 6. Dead Bug
struct AnimationDeadBug: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                // Torso
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 70, height: 18).offset(y: 45)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -45, y: 45)
                // Right arm extending up
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 40)
                    .rotationEffect(.degrees(animate ? -10 : 20))
                    .offset(x: animate ? -30 : -20, y: animate ? 10 : 28)
                // Left arm extending up
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 40)
                    .rotationEffect(.degrees(animate ? 20 : -10))
                    .offset(x: animate ? -20 : -30, y: animate ? 28 : 10)
                // Right leg extending
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 12, height: 42)
                    .rotationEffect(.degrees(animate ? 70 : 30))
                    .offset(x: animate ? 62 : 46, y: animate ? 36 : 18)
                // Left leg extending
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 12, height: 42)
                    .rotationEffect(.degrees(animate ? 30 : 70))
                    .offset(x: animate ? 46 : 62, y: animate ? 18 : 36)
                // Core highlight
                Ellipse().fill(Color.metallicGold.opacity(0.3))
                    .frame(width: 30, height: 14).offset(y: 42)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 7. Seated Spine Stretch
struct AnimationSeatedSpineStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 60)
                // Legs extended on floor
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 90, height: 14).offset(x: 25, y: 54)
                // Feet
                Ellipse().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 14, height: 10).offset(x: 74, y: 52)
                // Torso curling forward
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 60)
                    .rotationEffect(.degrees(animate ? 45 : 5))
                    .offset(x: animate ? -5 : -20, y: animate ? 28 : 15)
                // Spine highlight
                Capsule().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 6, height: 55)
                    .rotationEffect(.degrees(animate ? 45 : 5))
                    .offset(x: animate ? -5 : -20, y: animate ? 28 : 15)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? 15 : -22, y: animate ? 10 : -20)
                // Arms reaching forward
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 45, height: 9)
                    .rotationEffect(.degrees(animate ? 15 : -30))
                    .offset(x: animate ? 35 : 5, y: animate ? 18 : -10)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 8. The Hundred
struct AnimationTheHundred: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 58)
                // Upper back + head lifted
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 18)
                    .rotationEffect(.degrees(-15))
                    .offset(x: -45, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -72, y: 32)
                // Lower torso flat
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 40, height: 18).offset(x: -5, y: 48)
                // Legs at 45 degrees
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 70, height: 13)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 45, y: 25)
                // Arms pumping up and down
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 50, height: 9)
                    .offset(x: -30, y: animate ? 42 : 52)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 50, height: 9)
                    .offset(x: -30, y: animate ? 42 : 52)
                // Core engagement highlight
                Ellipse().fill(Color.metallicGold.opacity(animate ? 0.45 : 0.2))
                    .frame(width: 35, height: 14).offset(x: -5, y: 46)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 9. Roll Up
struct AnimationRollUp: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Legs flat
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 85, height: 14).offset(x: 30, y: 54)
                Ellipse().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 14, height: 10).offset(x: 76, y: 52)
                // Torso rolling up
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 65)
                    .rotationEffect(.degrees(animate ? 60 : 0))
                    .offset(x: animate ? 0 : -25, y: animate ? 20 : 22)
                // Spine highlight
                Capsule().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 5, height: 60)
                    .rotationEffect(.degrees(animate ? 60 : 0))
                    .offset(x: animate ? 0 : -25, y: animate ? 20 : 22)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? 22 : -28, y: animate ? -5 : -14)
                // Arms reaching forward / overhead
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 42, height: 9)
                    .rotationEffect(.degrees(animate ? 10 : 0))
                    .offset(x: animate ? 42 : -55, y: animate ? 8 : -20)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 10. One Leg Circle
struct AnimationOneLegCircle: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 58)
                // Torso flat
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 80, height: 18).offset(x: -15, y: 48)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -65, y: 48)
                // Grounded leg
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 80, height: 13).offset(x: 45, y: 50)
                // Circling leg - traces a circle path
                CirclingLeg(phase: phase)
                    .stroke(Color.metallicGold.opacity(0.15), lineWidth: 1)
                    .frame(width: 60, height: 60)
                    .offset(x: 30, y: 10)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(-70 + sin(phase * .pi * 2.0) * 25))
                    .offset(
                        x: 35 + cos(phase * .pi * 2.0) * 12,
                        y: 15 + sin(phase * .pi * 2.0) * 15
                    )
                // Hip highlight
                Circle().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 18, height: 18).offset(x: 20, y: 45)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

private struct CirclingLeg: Shape {
    var phase: CGFloat
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: rect)
        return p
    }
}

// MARK: - 11. Rolling Like a Ball
struct AnimationRollingLikeABall: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 60)
                // Tucked body ball
                Ellipse().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 50)
                    .rotationEffect(.degrees(animate ? -35 : 35))
                    .offset(x: animate ? -15 : 15, y: animate ? 25 : 35)
                // Head tucked
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 22, height: 22)
                    .offset(x: animate ? -25 : 5, y: animate ? 5 : 15)
                // Knees to chest
                Circle().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 16, height: 16)
                    .offset(x: animate ? -10 : 20, y: animate ? 2 : 12)
                // Hands on shins
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? -18 : 12, y: animate ? 12 : 22)
                // Spine curve highlight
                Circle().stroke(Color.vintagePink.opacity(0.3), lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .offset(x: animate ? -15 : 15, y: animate ? 20 : 30)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 12. Single Leg Stretch
struct AnimationSingleLegStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 58)
                // Torso lifted
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 60, height: 18)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -30, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -62, y: 32)
                // Bent knee pulled in
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 32, height: 12)
                    .rotationEffect(.degrees(animate ? -40 : 30))
                    .offset(x: animate ? 8 : 30, y: animate ? 30 : 42)
                // Extended leg
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(animate ? -25 : 0))
                    .offset(x: animate ? 50 : 35, y: animate ? 28 : 48)
                // Hands on knee
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? 0 : 25, y: animate ? 28 : 38)
                // Core highlight
                Ellipse().fill(Color.metallicGold.opacity(0.3))
                    .frame(width: 28, height: 14).offset(x: -8, y: 46)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 13. Double Leg Stretch
struct AnimationDoubleLegStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 58)
                // Head lifted
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -60, y: 32)
                // Torso
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 18)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -28, y: 42)
                // Arms extending overhead or circling in
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 45, height: 9)
                    .rotationEffect(.degrees(animate ? -30 : 15))
                    .offset(x: animate ? -65 : -20, y: animate ? 15 : 35)
                // Both legs extending out or pulling in
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: animate ? 75 : 35, height: 13)
                    .rotationEffect(.degrees(animate ? -20 : -5))
                    .offset(x: animate ? 48 : 15, y: animate ? 28 : 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.78))
                    .frame(width: animate ? 75 : 35, height: 12)
                    .rotationEffect(.degrees(animate ? -25 : -8))
                    .offset(x: animate ? 46 : 13, y: animate ? 34 : 46)
                // Core glow
                Ellipse().fill(Color.metallicGold.opacity(animate ? 0.4 : 0.2))
                    .frame(width: 30, height: 16).offset(x: -5, y: 46)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 14. The Saw
struct AnimationTheSaw: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 60)
                // Legs spread on floor
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(15))
                    .offset(x: 40, y: 50)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 40, y: 58)
                // Torso twisting
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55)
                    .rotationEffect(.degrees(animate ? 40 : -40))
                    .offset(x: animate ? 10 : -10, y: animate ? 25 : 25)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? 30 : -30, y: animate ? 2 : 2)
                // Arms in T extending to opposite foot
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 50, height: 9)
                    .rotationEffect(.degrees(animate ? 25 : -25))
                    .offset(x: animate ? 40 : -40, y: animate ? 20 : 20)
                // Oblique highlight
                Ellipse().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 20, height: 35)
                    .rotationEffect(.degrees(animate ? 40 : -40))
                    .offset(x: animate ? 5 : -5, y: 30)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 15. Swan Dive Prep
struct AnimationSwanDivePrep: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Legs flat on floor
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 90, height: 14).offset(x: 30, y: 56)
                // Pelvis grounded
                Ellipse().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 26, height: 18).offset(x: -12, y: 54)
                // Torso lifting into extension
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55)
                    .rotationEffect(.degrees(animate ? -25 : 8))
                    .offset(x: -30, y: animate ? 28 : 42)
                // Back extensor highlight
                Capsule().fill(Color.metallicGold.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 6, height: 50)
                    .rotationEffect(.degrees(animate ? -25 : 8))
                    .offset(x: -30, y: animate ? 28 : 42)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? -38 : -32, y: animate ? -2 : 18)
                // Arms supporting
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 9, height: 35)
                    .rotationEffect(.degrees(animate ? 10 : 0))
                    .offset(x: -42, y: animate ? 35 : 45)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 16. Side Kick Series
struct AnimationSideKickSeries: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Side-lying body
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 70, height: 18).offset(x: -10, y: 50)
                // Head propped on hand
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 22, height: 22).offset(x: -55, y: 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 8, height: 25).offset(x: -55, y: 48)
                // Bottom leg stable
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 70, height: 12).offset(x: 48, y: 54)
                // Top leg swinging front/back
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 72, height: 13)
                    .rotationEffect(.degrees(animate ? -20 : 20))
                    .offset(x: animate ? 38 : 52, y: animate ? 36 : 42)
                // Glute highlight
                Circle().fill(Color.metallicGold.opacity(0.35))
                    .frame(width: 20, height: 20).offset(x: 22, y: 48)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 17. Plank
struct AnimationPlank: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Straight body line in plank
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 120, height: 18)
                    .rotationEffect(.degrees(-5))
                    .offset(y: 42)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -68, y: 36)
                // Forearms on ground
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 9, height: 28)
                    .rotationEffect(.degrees(10))
                    .offset(x: -55, y: 50)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 9, height: 28)
                    .rotationEffect(.degrees(10))
                    .offset(x: -45, y: 50)
                // Toes
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: 65, y: 55)
                // Core engagement pulse
                Ellipse().fill(Color.metallicGold.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 45, height: 14).offset(y: 40)
                // Subtle breathing motion
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 120, height: 18)
                    .rotationEffect(.degrees(-5))
                    .offset(y: animate ? 41 : 43)
                    .opacity(0.001) // invisible driver for subtle motion
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 18. Mermaid Stretch
struct AnimationMermaidStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 62)
                // Seated Z-legs
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 40, height: 12)
                    .rotationEffect(.degrees(20))
                    .offset(x: 15, y: 56)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 35, height: 11)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 42, y: 52)
                // Torso lateral bend
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 60)
                    .rotationEffect(.degrees(animate ? 25 : -5))
                    .offset(x: animate ? 5 : -5, y: 22)
                // Oblique highlight
                Capsule().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 8, height: 40)
                    .rotationEffect(.degrees(animate ? 25 : -5))
                    .offset(x: animate ? 8 : -2, y: 25)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? 18 : -8, y: animate ? -10 : -12)
                // Arm reaching overhead in arc
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 50, height: 9)
                    .rotationEffect(.degrees(animate ? 60 : -20))
                    .offset(x: animate ? 25 : -15, y: animate ? -15 : -5)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 19. Spine Twist
struct AnimationSpineTwist: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 62)
                // Legs extended
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 80, height: 13).offset(x: 30, y: 56)
                // Torso upright with rotation
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55)
                    .rotation3DEffect(.degrees(animate ? 30 : -30), axis: (x: 0, y: 1, z: 0))
                    .offset(x: -15, y: 28)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? -8 : -22, y: -4)
                // Arms in T rotating
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 80, height: 9)
                    .rotationEffect(.degrees(animate ? 15 : -15))
                    .offset(x: animate ? -5 : -25, y: 12)
                // Oblique highlight
                Ellipse().fill(Color.vintagePink.opacity(0.3))
                    .frame(width: 18, height: 30)
                    .offset(x: animate ? -10 : -20, y: 30)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 20. Swimming
struct AnimationSwimming: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 60)
                // Prone torso
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 75, height: 18).offset(y: 50)
                // Head lifted slightly
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18).offset(x: -48, y: 44)
                // Right arm up / left arm down alternating
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 45, height: 9)
                    .rotationEffect(.degrees(animate ? -30 : -5))
                    .offset(x: -55, y: animate ? 32 : 44)
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 45, height: 9)
                    .rotationEffect(.degrees(animate ? -5 : -30))
                    .offset(x: -55, y: animate ? 44 : 32)
                // Right leg up / left leg down alternating
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 55, height: 12)
                    .rotationEffect(.degrees(animate ? -10 : 5))
                    .offset(x: 52, y: animate ? 42 : 52)
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 55, height: 12)
                    .rotationEffect(.degrees(animate ? 5 : -10))
                    .offset(x: 52, y: animate ? 52 : 42)
                // Back extensors highlight
                Capsule().fill(Color.metallicGold.opacity(animate ? 0.35 : 0.15))
                    .frame(width: 50, height: 8).offset(y: 48)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 21. Teaser
struct AnimationTeaser: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 62)
                // V-shape: torso lifting
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 58)
                    .rotationEffect(.degrees(animate ? -35 : 5))
                    .offset(x: animate ? -8 : -15, y: animate ? 22 : 35)
                // Legs lifting to match
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 70, height: 14)
                    .rotationEffect(.degrees(animate ? -35 : 0))
                    .offset(x: animate ? 28 : 30, y: animate ? 22 : 52)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? -15 : -18, y: animate ? -10 : 8)
                // Arms parallel to legs
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 45, height: 9)
                    .rotationEffect(.degrees(animate ? -30 : 5))
                    .offset(x: animate ? 15 : 10, y: animate ? 12 : 25)
                // Core glow
                Ellipse().fill(Color.metallicGold.opacity(animate ? 0.5 : 0.15))
                    .frame(width: 28, height: 16)
                    .offset(x: 0, y: animate ? 38 : 50)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 22. Side Plank
struct AnimationSidePlank: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 62)
                // Supporting arm
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 9, height: 40).offset(x: -50, y: 42)
                // Body line at angle
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 110, height: 16)
                    .rotationEffect(.degrees(-12))
                    .offset(x: 5, y: 30)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -52, y: 18)
                // Top arm reaching up
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 9, height: animate ? 45 : 35)
                    .rotationEffect(.degrees(animate ? 5 : -10))
                    .offset(x: -15, y: animate ? 2 : 10)
                // Feet stacked
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 12, height: 12).offset(x: 60, y: 56)
                // Oblique highlight
                Capsule().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: 40, height: 10)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -5, y: 30)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 23. Boomerang
struct AnimationBoomerang: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 62)
                // Rolling back phase vs V-sit phase
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55)
                    .rotationEffect(.degrees(animate ? -50 : 30))
                    .offset(x: animate ? -5 : 5, y: animate ? 18 : 35)
                // Legs crossed and lifting
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 60, height: 13)
                    .rotationEffect(.degrees(animate ? -40 : 60))
                    .offset(x: animate ? 25 : -5, y: animate ? 18 : 30)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? -15 : 15, y: animate ? -8 : 15)
                // Arms behind
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 40, height: 8)
                    .rotationEffect(.degrees(animate ? -20 : 45))
                    .offset(x: animate ? -25 : 10, y: animate ? 38 : 48)
                // Flow indicator arc
                Circle().stroke(Color.metallicGold.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 100, height: 100).offset(y: 25)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 24. Pilates Push-Up
struct AnimationPilatesPushUp: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 62)
                // Body in plank/push-up
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 110, height: 16)
                    .rotationEffect(.degrees(animate ? -2 : -8))
                    .offset(x: 5, y: animate ? 42 : 36)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18)
                    .offset(x: -55, y: animate ? 38 : 28)
                // Arms bending
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 9, height: animate ? 22 : 32)
                    .rotationEffect(.degrees(animate ? 15 : 5))
                    .offset(x: -40, y: animate ? 52 : 50)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 9, height: animate ? 22 : 32)
                    .rotationEffect(.degrees(animate ? 15 : 5))
                    .offset(x: -25, y: animate ? 52 : 50)
                // Pec highlight
                Ellipse().fill(Color.vintagePink.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 30, height: 12)
                    .offset(x: -35, y: animate ? 42 : 35)
                // Toes
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: 62, y: 58)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 25. Scissors
struct AnimationScissors: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 62)
                // Shoulders on ground, hips supported
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 16).offset(x: -20, y: 52)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -52, y: 52)
                // Hands supporting lower back
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: 0, y: 45)
                // One leg forward, one back (scissoring)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(animate ? -70 : -40))
                    .offset(x: animate ? 20 : 35, y: animate ? 10 : 28)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 13)
                    .rotationEffect(.degrees(animate ? -40 : -70))
                    .offset(x: animate ? 35 : 20, y: animate ? 28 : 10)
                // Hip flexor highlight
                Ellipse().fill(Color.vintagePink.opacity(0.3))
                    .frame(width: 20, height: 16).offset(x: 5, y: 42)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 26. Bicycle
struct AnimationBicycle: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 62)
                // Shoulders on ground
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 45, height: 16).offset(x: -25, y: 54)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -55, y: 54)
                // Hips elevated
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 30, height: 16)
                    .rotationEffect(.degrees(-60))
                    .offset(x: 5, y: 40)
                // Pedaling leg 1 (bent)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 35, height: 12)
                    .rotationEffect(.degrees(animate ? -80 : -30))
                    .offset(x: animate ? 15 : 32, y: animate ? 12 : 25)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 30, height: 11)
                    .rotationEffect(.degrees(animate ? 20 : -50))
                    .offset(x: animate ? 25 : 18, y: animate ? -2 : 8)
                // Pedaling leg 2 (extending)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 55, height: 12)
                    .rotationEffect(.degrees(animate ? -30 : -70))
                    .offset(x: animate ? 38 : 22, y: animate ? 30 : 15)
                // Quad highlight
                Capsule().fill(Color.vintagePink.opacity(0.3))
                    .frame(width: 30, height: 8)
                    .rotationEffect(.degrees(animate ? -30 : -70))
                    .offset(x: animate ? 35 : 18, y: animate ? 28 : 12)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 27. Hip Twist
struct AnimationHipTwist: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 62)
                // Seated torso upright, hands behind
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 50).offset(x: -20, y: 30)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -20, y: 0)
                // Arms behind for support
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 30, height: 8)
                    .rotationEffect(.degrees(20))
                    .offset(x: -38, y: 55)
                // Legs circling in the air
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 14)
                    .rotationEffect(.degrees(-45 + sin(phase * .pi * 2.0) * 20))
                    .offset(
                        x: 25 + cos(phase * .pi * 2.0) * 10,
                        y: 25 + sin(phase * .pi * 2.0) * 12
                    )
                // Circle path indicator
                Circle().stroke(Color.metallicGold.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 50, height: 50).offset(x: 25, y: 22)
                // Oblique highlight
                Ellipse().fill(Color.metallicGold.opacity(0.3))
                    .frame(width: 16, height: 28).offset(x: -18, y: 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - 28. Seal
struct AnimationSeal: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 140, height: 6).offset(y: 62)
                // Rounded body rocking
                Ellipse().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 48)
                    .rotationEffect(.degrees(animate ? -30 : 30))
                    .offset(x: animate ? -10 : 10, y: animate ? 28 : 38)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? -22 : 0, y: animate ? 8 : 18)
                // Feet clapping together
                Ellipse().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: animate ? 16 : 28, height: 12)
                    .offset(x: animate ? -5 : 15, y: animate ? 15 : 25)
                // Hands through ankles
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? -12 : 8, y: animate ? 18 : 28)
                // Spine curve
                Circle().stroke(Color.vintagePink.opacity(0.25), lineWidth: 2)
                    .frame(width: 45, height: 45)
                    .offset(x: animate ? -10 : 10, y: animate ? 25 : 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 29. Wall Roll Down
struct AnimationWallRollDown: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                // Wall
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -60, y: 0)
                // Floor
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 65)
                // Legs
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 55).offset(x: -30, y: 35)
                Capsule().fill(Color.deepCharcoal.opacity(0.78))
                    .frame(width: 14, height: 55).offset(x: -20, y: 35)
                // Feet
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 20, height: 8).offset(x: -25, y: 62)
                // Upper body rolling down from wall
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55)
                    .rotationEffect(.degrees(animate ? 50 : 0))
                    .offset(x: animate ? -20 : -48, y: animate ? 15 : -15)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20)
                    .offset(x: animate ? 0 : -50, y: animate ? 28 : -45)
                // Spine highlight
                Capsule().fill(Color.vintagePink.opacity(0.3))
                    .frame(width: 6, height: 50)
                    .rotationEffect(.degrees(animate ? 50 : 0))
                    .offset(x: animate ? -20 : -48, y: animate ? 15 : -15)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 30. Wall Sit
struct AnimationWallSit: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            ZStack {
                // Wall
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -55, y: 0)
                // Floor
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 65)
                // Back against wall
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 50).offset(x: -48, y: 5)
                // Head
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -48, y: -28)
                // Thighs horizontal
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 40, height: 14).offset(x: -22, y: 32)
                // Shins vertical
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 36).offset(x: 0, y: 48)
                // Quad burn highlight
                Capsule().fill(Color.metallicGold.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 35, height: 10).offset(x: -22, y: 32)
                // Subtle shake for isometric hold
                Capsule().fill(Color.deepCharcoal.opacity(0.001))
                    .frame(width: 18, height: 50)
                    .offset(x: -48, y: animate ? 4 : 6)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - 31. Wall Glute Bridge
struct AnimationWallGluteBridge: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 120).offset(x: 65, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 18).offset(x: -25, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -58, y: 42)
                Capsule().fill(Color.vintagePink.opacity(0.5))
                    .frame(width: 22, height: 14).offset(x: 5, y: animate ? 28 : 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 40, height: 13).rotationEffect(.degrees(-50))
                    .offset(x: 30, y: animate ? 18 : 28)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 14, height: 10).offset(x: 58, y: 5)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 32. Wall Push-Ups
struct AnimationWallPushUps: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -60, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 65)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 60).rotationEffect(.degrees(animate ? -15 : -25))
                    .offset(x: -20, y: 10)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: animate ? -30 : -40, y: -25)
                Capsule().fill(Color.vintagePink.opacity(0.5))
                    .frame(width: animate ? 25 : 15, height: 10).offset(x: -45, y: 0)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 50).rotationEffect(.degrees(-10)).offset(x: 5, y: 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 33. Wall Inverted Plank
struct AnimationWallInvertedPlank: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: 65, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 65)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 30, height: 10).offset(x: -40, y: 58)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 70).rotationEffect(.degrees(25)).offset(x: 0, y: 20)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18).offset(x: -30, y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 12, height: 10).offset(x: 55, y: -15)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 14, height: 25).rotationEffect(.degrees(25)).offset(x: 0, y: 20)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 34. Wall Leg Abduction
struct AnimationWallLegAbduction: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -60, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 65)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 50).offset(x: -48, y: 10)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -48, y: -22)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 45).offset(x: -48, y: 45)
                Capsule().fill(Color.vintagePink.opacity(0.6))
                    .frame(width: 14, height: 45)
                    .rotationEffect(.degrees(animate ? -45 : 0), anchor: .top).offset(x: -40, y: 38)
                Circle().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 14, height: 14).offset(x: -42, y: 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 35. Wall Pulse Squats
struct AnimationWallPulseSquats: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -55, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 65)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 50).offset(x: -48, y: animate ? 3 : 8)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -48, y: animate ? -26 : -21)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 40, height: 14).offset(x: -22, y: animate ? 30 : 35)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 36).offset(x: 0, y: 48)
                Capsule().fill(Color.metallicGold.opacity(animate ? 0.6 : 0.15))
                    .frame(width: 35, height: 10).offset(x: -22, y: animate ? 30 : 35)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 36. Wall Calf Raises
struct AnimationWallCalfRaises: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: -55, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 160, height: 6).offset(y: 65)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 55).offset(x: -20, y: animate ? -5 : 5)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -20, y: animate ? -38 : -28)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 40).offset(x: -20, y: animate ? 35 : 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 20, height: 8).offset(x: -42, y: 0)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 10, height: 20).offset(x: -20, y: animate ? 48 : 52)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 37. Wall Hamstring Stretch
struct AnimationWallHamstringStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: 65, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 18).offset(x: -10, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -42, y: 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 60).offset(x: 55, y: 10)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 10, height: 30).offset(x: 55, y: 20)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 38. Legs Up the Wall
struct AnimationLegsUpTheWall: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.nudeModern.opacity(0.25))
                    .frame(width: 8, height: 140).offset(x: 65, y: 0)
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 180, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 50, height: 18).offset(x: -5, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -38, y: 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 65).offset(x: 55, y: 5)
                Circle().fill(Color.metallicGold.opacity(animate ? 0.12 : 0.04))
                    .frame(width: 100, height: 100).offset(x: 10, y: 20)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 39. Bed Pelvic Tilt
struct AnimationBedPelvicTilt: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.nudeModern.opacity(0.2))
                    .frame(width: 200, height: 20).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 70, height: 18).offset(x: -15, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -58, y: 38)
                Capsule().fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 28, height: 10).offset(x: -58, y: 46)
                Capsule().fill(Color.vintagePink.opacity(0.5))
                    .frame(width: 22, height: 14).rotationEffect(.degrees(animate ? 8 : -8))
                    .offset(x: 20, y: 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 30, height: 12).rotationEffect(.degrees(-55)).offset(x: 48, y: 22)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 40. Supine Spinal Twist
struct AnimationSupineSpinalTwist: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.nudeModern.opacity(0.2))
                    .frame(width: 200, height: 20).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 65, height: 18).offset(x: -10, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: animate ? -50 : -45, y: 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 50, height: 8).offset(x: -10, y: 28)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 28, height: 12).rotationEffect(.degrees(animate ? -30 : 30))
                    .offset(x: 35, y: 28)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 40, height: 6).offset(x: -10, y: 38)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 41. Gentle Bed Bridge
struct AnimationGentleBedBridge: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.nudeModern.opacity(0.2))
                    .frame(width: 200, height: 20).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 40, height: 18).offset(x: -35, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -60, y: 38)
                Capsule().fill(Color.vintagePink.opacity(0.5))
                    .frame(width: 22, height: 14).offset(x: -5, y: animate ? 25 : 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 35, height: 12).rotationEffect(.degrees(animate ? -25 : -10))
                    .offset(x: 20, y: animate ? 22 : 32)
                Capsule().fill(Color.deepCharcoal.opacity(0.75))
                    .frame(width: 20, height: 10).offset(x: 45, y: 44)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 42. Bed Leg Raise
struct AnimationBedLegRaise: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.nudeModern.opacity(0.2))
                    .frame(width: 200, height: 20).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 80, height: 18).offset(x: -10, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -58, y: 38)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 50, height: 12).offset(x: 50, y: 38)
                Capsule().fill(Color.vintagePink.opacity(0.6))
                    .frame(width: 50, height: 12)
                    .rotationEffect(.degrees(animate ? -70 : 0), anchor: .leading).offset(x: 35, y: 38)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 43. Relaxation Breathing
struct AnimationRelaxationBreathing: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.nudeModern.opacity(0.2))
                    .frame(width: 200, height: 20).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 80, height: 18).offset(x: -5, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -52, y: 38)
                Circle().fill(Color.deepCharcoal.opacity(0.7))
                    .frame(width: 10, height: 10).offset(x: 5, y: 30)
                Ellipse().fill(Color.vintagePink.opacity(0.35))
                    .frame(width: animate ? 35 : 25, height: animate ? 20 : 14).offset(x: 5, y: 30)
                Circle().stroke(Color.metallicGold.opacity(animate ? 0.4 : 0.0), lineWidth: 1.5)
                    .frame(width: animate ? 60 : 20, height: animate ? 60 : 20).offset(x: 5, y: 25)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 55, height: 12).offset(x: 50, y: 38)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 44. Corkscrew
struct AnimationCorkscrew: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 75, height: 18).offset(x: -15, y: 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -58, y: 42)
                Capsule().fill(Color.vintagePink.opacity(0.6))
                    .frame(width: 14, height: 55)
                    .rotationEffect(.degrees(animate ? -15 : 15), anchor: .bottom)
                    .offset(x: animate ? 35 : 25, y: -5)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 55)
                    .rotationEffect(.degrees(animate ? -15 : 15), anchor: .bottom)
                    .offset(x: animate ? 30 : 20, y: -2)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 20, height: 10).offset(x: 5, y: 42)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 45. Jackknife
struct AnimationJackknife: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 55, height: 18).offset(x: -25, y: animate ? 30 : 42)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 20, height: 20).offset(x: -55, y: animate ? 28 : 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 14, height: 60)
                    .rotationEffect(.degrees(animate ? -10 : 0), anchor: .bottom)
                    .offset(x: 15, y: animate ? -15 : 15)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 18, height: 12).offset(x: 0, y: animate ? 28 : 40)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 46. Pigeon Stretch
struct AnimationPigeonStretch: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 35, height: 12).offset(x: -20, y: 48)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 65, height: 12).offset(x: 40, y: 48)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 45)
                    .rotationEffect(.degrees(animate ? 45 : 20)).offset(x: -20, y: animate ? 20 : 15)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18).offset(x: animate ? -5 : -15, y: animate ? 38 : 5)
                Circle().fill(Color.vintagePink.opacity(animate ? 0.5 : 0.2))
                    .frame(width: 16, height: 16).offset(x: -10, y: 42)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 47. Plank Leg Lift
struct AnimationPlankLegLift: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 100, height: 16).offset(x: 0, y: 30)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18).offset(x: -56, y: 28)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 25).rotationEffect(.degrees(5)).offset(x: -45, y: 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 25).offset(x: 45, y: 42)
                Capsule().fill(Color.vintagePink.opacity(0.6))
                    .frame(width: 10, height: 30)
                    .rotationEffect(.degrees(animate ? -30 : 0), anchor: .bottom).offset(x: 55, y: 30)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 25, height: 10).offset(x: 0, y: 30)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { animate = true } }
    }
}

// MARK: - 48. Thoracic Rotation
struct AnimationThoracicRotation: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle().fill(Color.vintagePink.opacity(0.08)).frame(width: 240, height: 240)
            Circle().stroke(Color.metallicGold.opacity(animate ? 0.25 : 0.08), lineWidth: 2)
                .frame(width: animate ? 200 : 180, height: animate ? 200 : 180)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.nudeModern.opacity(0.3))
                    .frame(width: 200, height: 6).offset(y: 55)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 22).offset(x: -35, y: 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.8))
                    .frame(width: 10, height: 22).offset(x: 35, y: 42)
                Capsule().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 65, height: 16).offset(y: 25)
                Circle().fill(Color.deepCharcoal.opacity(0.85))
                    .frame(width: 18, height: 18).offset(x: -38, y: 22)
                Capsule().fill(Color.vintagePink.opacity(0.6))
                    .frame(width: 10, height: 30)
                    .rotationEffect(.degrees(animate ? -80 : 0), anchor: .bottom).offset(x: 15, y: 15)
                Capsule().fill(Color.vintagePink.opacity(animate ? 0.4 : 0.15))
                    .frame(width: 30, height: 8).offset(y: 22)
            }
        }
        .frame(width: 280, height: 280)
        .onAppear { withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

