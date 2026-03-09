import SwiftUI

struct OnboardingFaceTransformView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showContent = false
    @State private var animateAfter = false

    var body: some View {
        OnboardingScreenLayout(step: 32, onBack: onBack) {
            VStack(spacing: 0) {
                Text("Voyez votre futur\nvisage plus affiné")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .opacity(showContent ? 1 : 0)

                Spacer().frame(height: 32)

                // Before → After face comparison
                HStack(spacing: 32) {
                    // BEFORE
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.vintagePink)
                            .opacity(showContent ? 1 : 0)

                        Text("Aujourd'hui")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                    }

                    // Arrow
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.metallicGold)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.5)

                    // AFTER
                    VStack(spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(.metallicGold)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.metallicGold)
                                .offset(x: 10, y: -5)
                                .opacity(animateAfter ? 1 : 0)
                        }
                        .shadow(color: Color.metallicGold.opacity(0.3), radius: 15)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)

                        Text("Objectif")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.metallicGold)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 36)

                // Benefits list
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(icon: "sparkles", text: "Visage plus affiné et défini")
                    benefitRow(icon: "heart.fill", text: "Pommettes plus visibles")
                    benefitRow(icon: "face.smiling", text: "Mâchoire plus sculptée")
                }
                .padding(.horizontal, 32)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

                Spacer().frame(height: 24)

                Text("La perte de poids se voit souvent d'abord sur le visage. Notre programme est conçu pour des résultats harmonieux.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                SuivantButton(isEnabled: true, action: onNext)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            // Animate the face slimming after a brief delay
            withAnimation(.easeInOut(duration: 1.2).delay(0.8)) {
                animateAfter = true
            }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.metallicGold)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.deepCharcoal)
        }
    }
}

#Preview {
    OnboardingFaceTransformView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
