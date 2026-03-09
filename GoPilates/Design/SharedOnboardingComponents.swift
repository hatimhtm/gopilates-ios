import SwiftUI

// MARK: - Realistic Feminine Body Silhouette (Shared)
// Uses Path with bezier curves to create a realistic feminine body outline
// that can morph between slim and curvy body types.

struct RealisticBodySilhouette: View {
    /// 0.0 = very slim, 1.0 = curvy/ample
    var curviness: CGFloat = 0.5
    var highlightColor: Color = Color.vintagePink
    var baseColor: Color = Color.nudeModern.opacity(0.4)
    
    // Which zones are highlighted (for body zone view)
    var highlightArms: Bool = false
    var highlightCore: Bool = false
    var highlightLegs: Bool = false
    var highlightAll: Bool = false
    
    private var armsActive: Bool { highlightAll || highlightArms }
    private var coreActive: Bool { highlightAll || highlightCore }
    private var legsActive: Bool { highlightAll || highlightLegs }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            
            // Scale factors based on curviness
            let shoulderW = w * (0.32 + curviness * 0.06)
            let bustW = w * (0.26 + curviness * 0.08)
            let waistW = w * (0.18 + curviness * 0.06)
            let hipW = w * (0.28 + curviness * 0.1)
            
            ZStack {
                // BODY SHAPE — single unified path
                Path { p in
                    let headR = w * 0.09
                    let neckY = h * 0.15
                    let shoulderY = h * 0.2
                    let bustY = h * 0.3
                    let waistY = h * 0.4
                    let hipY = h * 0.5
                    let kneeY = h * 0.72
                    let ankleY = h * 0.9
                    
                    // Head
                    p.addEllipse(in: CGRect(x: cx - headR, y: h * 0.02, width: headR * 2, height: headR * 2.2))
                    
                    // Neck
                    p.addRoundedRect(in: CGRect(x: cx - w * 0.04, y: h * 0.12, width: w * 0.08, height: neckY - h * 0.12), cornerSize: CGSize(width: 4, height: 4))
                    
                    // Torso (shoulders to hips) — left side
                    p.move(to: CGPoint(x: cx - shoulderW, y: shoulderY))
                    // Shoulder to bust
                    p.addCurve(
                        to: CGPoint(x: cx - bustW, y: bustY),
                        control1: CGPoint(x: cx - shoulderW, y: shoulderY + h * 0.04),
                        control2: CGPoint(x: cx - bustW - w * 0.02, y: bustY - h * 0.03)
                    )
                    // Bust to waist (inward curve)
                    p.addCurve(
                        to: CGPoint(x: cx - waistW, y: waistY),
                        control1: CGPoint(x: cx - bustW + w * 0.01, y: bustY + h * 0.04),
                        control2: CGPoint(x: cx - waistW - w * 0.01, y: waistY - h * 0.03)
                    )
                    // Waist to hips (outward curve)
                    p.addCurve(
                        to: CGPoint(x: cx - hipW, y: hipY),
                        control1: CGPoint(x: cx - waistW - w * 0.02, y: waistY + h * 0.03),
                        control2: CGPoint(x: cx - hipW - w * 0.02, y: hipY - h * 0.03)
                    )
                    
                    // Left leg
                    let legInset = w * 0.03
                    p.addCurve(
                        to: CGPoint(x: cx - legInset - w * 0.07, y: kneeY),
                        control1: CGPoint(x: cx - hipW, y: hipY + h * 0.06),
                        control2: CGPoint(x: cx - legInset - w * 0.1, y: kneeY - h * 0.05)
                    )
                    p.addCurve(
                        to: CGPoint(x: cx - legInset - w * 0.05, y: ankleY),
                        control1: CGPoint(x: cx - legInset - w * 0.05, y: kneeY + h * 0.05),
                        control2: CGPoint(x: cx - legInset - w * 0.06, y: ankleY - h * 0.04)
                    )
                    // Foot
                    p.addLine(to: CGPoint(x: cx - legInset + w * 0.02, y: ankleY))
                    // Back up the inner left leg
                    p.addCurve(
                        to: CGPoint(x: cx - legInset, y: kneeY),
                        control1: CGPoint(x: cx - legInset + w * 0.01, y: ankleY - h * 0.04),
                        control2: CGPoint(x: cx - legInset + w * 0.01, y: kneeY + h * 0.05)
                    )
                    p.addLine(to: CGPoint(x: cx - legInset, y: hipY + h * 0.02))
                    
                    // Crotch gap
                    p.addLine(to: CGPoint(x: cx + legInset, y: hipY + h * 0.02))
                    
                    // Right inner leg down
                    p.addLine(to: CGPoint(x: cx + legInset, y: kneeY))
                    p.addCurve(
                        to: CGPoint(x: cx + legInset - w * 0.02, y: ankleY),
                        control1: CGPoint(x: cx + legInset - w * 0.01, y: kneeY + h * 0.05),
                        control2: CGPoint(x: cx + legInset - w * 0.01, y: ankleY - h * 0.04)
                    )
                    // Right foot
                    p.addLine(to: CGPoint(x: cx + legInset + w * 0.05, y: ankleY))
                    // Right outer leg up
                    p.addCurve(
                        to: CGPoint(x: cx + legInset + w * 0.07, y: kneeY),
                        control1: CGPoint(x: cx + legInset + w * 0.06, y: ankleY - h * 0.04),
                        control2: CGPoint(x: cx + legInset + w * 0.05, y: kneeY + h * 0.05)
                    )
                    // Right leg to hip
                    p.addCurve(
                        to: CGPoint(x: cx + hipW, y: hipY),
                        control1: CGPoint(x: cx + legInset + w * 0.1, y: kneeY - h * 0.05),
                        control2: CGPoint(x: cx + hipW, y: hipY + h * 0.06)
                    )
                    // Hip to waist (right side)
                    p.addCurve(
                        to: CGPoint(x: cx + waistW, y: waistY),
                        control1: CGPoint(x: cx + hipW + w * 0.02, y: hipY - h * 0.03),
                        control2: CGPoint(x: cx + waistW + w * 0.02, y: waistY + h * 0.03)
                    )
                    // Waist to bust (right side)
                    p.addCurve(
                        to: CGPoint(x: cx + bustW, y: bustY),
                        control1: CGPoint(x: cx + waistW + w * 0.01, y: waistY - h * 0.03),
                        control2: CGPoint(x: cx + bustW - w * 0.01, y: bustY + h * 0.04)
                    )
                    // Bust to shoulder (right side)
                    p.addCurve(
                        to: CGPoint(x: cx + shoulderW, y: shoulderY),
                        control1: CGPoint(x: cx + bustW + w * 0.02, y: bustY - h * 0.03),
                        control2: CGPoint(x: cx + shoulderW, y: shoulderY + h * 0.04)
                    )

                    p.closeSubpath()
                    
                    // Left arm
                    let armStartY = shoulderY + h * 0.01
                    let armW = w * 0.04
                    p.addRoundedRect(
                        in: CGRect(x: cx - shoulderW - armW * 1.5, y: armStartY, width: armW, height: h * 0.28),
                        cornerSize: CGSize(width: armW / 2, height: armW / 2)
                    )
                    
                    // Right arm
                    p.addRoundedRect(
                        in: CGRect(x: cx + shoulderW + armW * 0.5, y: armStartY, width: armW, height: h * 0.28),
                        cornerSize: CGSize(width: armW / 2, height: armW / 2)
                    )
                }
                .fill(
                    LinearGradient(
                        colors: [
                            highlightAll ? highlightColor : baseColor,
                            highlightAll ? highlightColor.opacity(0.7) : baseColor.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Zone overlays (arms glow)
                if armsActive && !highlightAll {
                    let armW = w * 0.04
                    let shoulderY = h * 0.2
                    let shoulderW = w * (0.32 + curviness * 0.06)
                    Group {
                        RoundedRectangle(cornerRadius: armW / 2)
                            .fill(highlightColor)
                            .frame(width: armW, height: h * 0.28)
                            .position(x: cx - shoulderW - armW, y: shoulderY + h * 0.15)
                        RoundedRectangle(cornerRadius: armW / 2)
                            .fill(highlightColor)
                            .frame(width: armW, height: h * 0.28)
                            .position(x: cx + shoulderW + armW, y: shoulderY + h * 0.15)
                    }
                    .shadow(color: highlightColor.opacity(0.4), radius: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: curviness)
        .animation(.easeInOut(duration: 0.3), value: highlightAll)
        .animation(.easeInOut(duration: 0.3), value: armsActive)
        .animation(.easeInOut(duration: 0.3), value: coreActive)
        .animation(.easeInOut(duration: 0.3), value: legsActive)
    }
}

// MARK: - Animated Number Display (for pickers)

struct AnimatedNumberDisplay: View {
    let value: String
    let unit: String
    let fontSize: CGFloat
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(.deepCharcoal)
                .id("num_\(value)") // Forces view replacement
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.2).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: value)

            Text(unit)
                .font(.system(size: fontSize * 0.33, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.5))
        }
    }
}


// MARK: - Continuous Weight Picker

/// A custom wheel picker that uses iOS 17 ScrollView features
/// to provide continuous, real-time binding updates as the user scrolls,
/// unlike the standard Apple Picker which only updates when scrolling comes to a complete rest.
struct ContinuousWeightPicker: View {
    let values: [Double]
    @Binding var selection: Int?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(0..<values.count, id: \.self) { i in
                    Text(String(format: "%.1f", values[i]))
                        .font(.system(size: 22, weight: selection == i ? .bold : .medium))
                        .foregroundColor(selection == i ? .deepCharcoal : .deepCharcoal.opacity(0.3))
                        .frame(height: 44)
                        .id(i)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $selection, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.vertical, (150 - 44) / 2) // Centers the first and last items
        .frame(height: 150)
        .overlay(
            VStack {
                Rectangle()
                    .fill(Color.deepCharcoal.opacity(0.1))
                    .frame(height: 1.5)
                Spacer()
                Rectangle()
                    .fill(Color.deepCharcoal.opacity(0.1))
                    .frame(height: 1.5)
            }
            .frame(height: 44)
        )
        .clipped()
        .onChange(of: selection) { _, _ in
            HapticManager.selection()
        }
    }
}

#Preview("Body Silhouette") {
    VStack {
        RealisticBodySilhouette(curviness: 0.5, highlightAll: true)
            .frame(width: 120, height: 300)
    }
    .padding()
}
