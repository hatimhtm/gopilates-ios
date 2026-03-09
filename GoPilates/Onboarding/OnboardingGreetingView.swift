import SwiftUI

struct OnboardingGreetingView: View {
    var onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                // Lottie lotus bloom animation
                LottieView(animationName: "onboarding_greeting", loopMode: .loop, animationSpeed: 1.0)
                    .frame(width: 200, height: 200)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 40)

                // Title
                Text("Bonjour,\nje suis votre\ncoach personnel.")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)

                Spacer().frame(height: 20)

                // Subtitle
                Text("Nous allons vous poser quelques questions pour personnaliser un plan de Pilates unique pour vous.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)

                Spacer()

                // CTA Button
                SuivantButton(title: "C'est parti !", isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

#Preview {
    OnboardingGreetingView(onNext: {})
        .environment(OnboardingData())
}
