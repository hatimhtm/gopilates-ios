import SwiftUI

struct OnboardingNameView: View {
    @Environment(OnboardingData.self) var data
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Decorative Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.vintagePink.opacity(0.2), Color.champagneBlush],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.vintagePink.opacity(0.6))
            }

            VStack(spacing: 10) {
                Text("Comment vous appelez-vous ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)

                Text("Pour personnaliser votre expérience")
                    .font(.system(size: 15))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
            }

            // Name Input — simple, no heavy animation
            VStack(spacing: 8) {
                TextField("Votre prénom", text: $name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(name.isEmpty ? Color.white.opacity(0.4) : Color.vintagePink.opacity(0.5), lineWidth: 1.5)
                    )
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 40)

            Spacer()

            GoldButton(title: "Continuer") {
                data.userName = name.trimmingCharacters(in: .whitespaces)
                onNext()
            }
            .padding(.horizontal, 24)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

            Spacer().frame(height: 40)
        }
    }
}

#Preview {
    OnboardingNameView(onNext: {}, onBack: {})
        .environment(OnboardingData())
}
