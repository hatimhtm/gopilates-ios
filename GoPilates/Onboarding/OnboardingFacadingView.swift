import SwiftUI

struct OnboardingFacadingView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void

    @State private var progress: CGFloat = 0
    @State private var currentPhase: Int = 0

    private let statuses = [
        "Analyse de vos objectifs...",
        "Calcul de votre métabolisme...",
        "Optimisation des zones cibles...",
        "Personnalisation des exercices...",
        "Préparation de votre programme..."
    ]

    /// Lottie animation speed increases as progress advances
    private var lottieSpeed: Double {
        1.0 + Double(progress) * 1.5
    }

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack(spacing: 32) {
                // Lottie loading ring animation
                ZStack {
                    LottieView(
                        animationName: "onboarding_loading",
                        loopMode: .loop,
                        animationSpeed: lottieSpeed
                    )
                    .frame(width: 180, height: 180)

                    AnimatablePercentageText(progress: progress)
                }

                VStack(spacing: 12) {
                    // FIXED: Use ZStack to prevent text overlap — only one text visible at a time
                    ZStack {
                        ForEach(0..<statuses.count, id: \.self) { index in
                            Text(statuses[index])
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.deepCharcoal)
                                .opacity(currentPhase == index ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: currentPhase)
                        }
                    }
                    .frame(height: 26)

                    Text("Cela ne prendra que quelques secondes")
                        .font(.system(size: 14))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                }
            }
        }
        .onAppear {
            startFacading()
            // Pre-load RevenueCat offerings during the fake loading screen
            // so they're ready when the paywall appears
            Task {
                await SubscriptionManager.shared.ensureOfferingsLoaded()
            }
        }
    }

    private func startFacading() {
        // Phase 0: Start
        currentPhase = 0
        withAnimation(.easeOut(duration: 0.6)) {
            progress = 0.18
        }
        
        // Phase 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            currentPhase = 1
            withAnimation(.easeInOut(duration: 1.2)) {
                progress = 0.45
            }
        }
        
        // Phase 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            currentPhase = 2
            withAnimation(.easeOut(duration: 0.5)) {
                progress = 0.72
            }
        }
        
        // Phase 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.9) {
            currentPhase = 3
            withAnimation(.linear(duration: 1.5)) {
                progress = 0.88
            }
        }
        
        // Phase 4
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) {
            currentPhase = 4
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 1.0
            }
        }

        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            onNext()
        }
    }
}

struct AnimatablePercentageText: View, Animatable {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Text("\(Int(progress * 100))%")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.deepCharcoal)
    }
}

#Preview {
    OnboardingFacadingView(onNext: {})
        .environment(OnboardingData())
}
