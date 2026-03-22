import SwiftUI
import RevenueCat
import SafariServices

struct OnboardingPaywallView: View {
    @Environment(OnboardingData.self) var data
    var onBack: () -> Void
    var onComplete: () -> Void

    @State private var selectedPlan: String = "Annuel"
    @State private var showingPaymentSuccess = false
    @State private var pulse = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var isPurchasing = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    private var annualPrice: String {
        guard let offering = SubscriptionManager.shared.currentOffering,
              let package = offering.availablePackages.first(where: { $0.packageType == .annual }) else {
            return "39,99€ / an (soit 3,33€/mois)"
        }
        return "\(package.localizedPriceString) / an"
    }

    private var monthlyPrice: String {
        guard let offering = SubscriptionManager.shared.currentOffering,
              let package = offering.availablePackages.first(where: { $0.packageType == .monthly }) else {
            return "9,99€ / mois"
        }
        return "\(package.localizedPriceString) / mois"
    }

    private var ctaTitle: String {
        selectedPlan == "Annuel"
            ? "3 jours gratuits, puis \(annualPrice)"
            : "S'abonner — \(monthlyPrice)"
    }

    var body: some View {
        ZStack {
            // Dark Premium Background
            Color.deepCharcoal.ignoresSafeArea()
            
            // Ambient glowing orbs
            Circle()
                .fill(Color.metallicGold.opacity(0.15))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: -150, y: -250)
            
            Circle()
                .fill(Color.vintagePink.opacity(0.15))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 150, y: 300)

            VStack(spacing: 0) {
                // Header (Back button + Logo)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // Hero Section
                        VStack(spacing: 16) {
                            Text("GO")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.metallicGold)
                                .kerning(4)
                            + Text("PILATES")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                                .kerning(4)
                            
                            Text(selectedPlan == "Annuel"
                                 ? "3 jours gratuits,\npuis \(annualPrice)"
                                 : "Accès illimité\nà GoPilates")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)
                                .animation(.easeInOut, value: selectedPlan)

                            Text("Abonnement GoPilates Premium. Rejoignez plus de 100 000 femmes qui ont transformé leur corps et leur esprit.")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 16)

                        // Feature list (Glassmorphic)
                        VStack(alignment: .leading, spacing: 20) {
                            PremiumFeatureRow(icon: "sparkles", text: "Programme unique basé sur votre profil")
                            PremiumFeatureRow(icon: "play.tv.fill", text: "Accès illimité à toute la bibliothèque VOD")
                            PremiumFeatureRow(icon: "flame.fill", text: "Défis 30 jours et Séances Flash 15min")
                            PremiumFeatureRow(icon: "chart.bar.fill", text: "Suivi de progression et rappels quotidiens")
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)

                        // Pricing cards
                        VStack(spacing: 16) {
                            PremiumPriceCard(
                                title: "Annuel",
                                subtitle: annualPrice,
                                badge: "3 jours offerts",
                                isSelected: selectedPlan == "Annuel"
                            ) {
                                HapticManager.selection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedPlan = "Annuel" }
                            }

                            PremiumPriceCard(
                                title: "Mensuel",
                                subtitle: monthlyPrice,
                                badge: nil,
                                isSelected: selectedPlan == "Mensuel"
                            ) {
                                HapticManager.selection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedPlan = "Mensuel" }
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 20)
                    }
                }
                
                // Sticky Footer
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            // Ensure offerings are loaded before attempting purchase
                            if SubscriptionManager.shared.currentOffering == nil {
                                await SubscriptionManager.shared.ensureOfferingsLoaded()
                            }

                            guard let offering = SubscriptionManager.shared.currentOffering else {
                                errorMessage = "Connexion requise : Impossible de charger les abonnements. Veuillez vérifier votre connexion internet."
                                showError = true
                                return
                            }
                            
                            let packageType: RevenueCat.PackageType = selectedPlan == "Annuel" ? .annual : .monthly
                            guard let package = offering.availablePackages.first(where: { $0.packageType == packageType }) else {
                                errorMessage = "Forfait introuvable. Veuillez réessayer plus tard."
                                showError = true
                                return
                            }
                            
                            isPurchasing = true
                            
                            do {
                                let success = try await SubscriptionManager.shared.purchase(package: package)
                                isPurchasing = false
                                if success {
                                    HapticManager.notification(.success)
                                    withAnimation { showingPaymentSuccess = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onComplete() }
                                }
                            } catch {
                                isPurchasing = false
                                
                                // Check error codes (domain string varies between RevenueCat SDK versions)
                                let nsError = error as NSError
                                if nsError.code == 1 /* purchaseCancelledError */ {
                                    // User cancelled — do nothing, no error message needed
                                } else if nsError.code == 7 /* productAlreadyPurchasedError */ {
                                    // Already purchased — restore to get the entitlement properly
                                    await SubscriptionManager.shared.restorePurchases()
                                    if SubscriptionManager.shared.isProEntitled {
                                        HapticManager.notification(.success)
                                        withAnimation { showingPaymentSuccess = true }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onComplete() }
                                    }
                                } else {
                                    errorMessage = "L'achat a échoué. Veuillez vérifier votre connexion internet et réessayer."
                                    showError = true
                                }
                            }
                        }
                    }) {
                        ZStack {
                            if isPurchasing || SubscriptionManager.shared.isLoadingOfferings {
                                ProgressView()
                                    .tint(.deepCharcoal)
                            } else {
                                Text(ctaTitle)
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .foregroundColor(.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(colors: [Color.metallicGold, Color(red: 236/255, green: 205/255, blue: 139/255)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .shadow(color: Color.metallicGold.opacity(0.4), radius: 15, y: 8)
                        .scaleEffect(pulse ? 1.02 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing || SubscriptionManager.shared.isLoadingOfferings)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                        // Retry loading offerings if they weren't loaded yet
                        Task {
                            await SubscriptionManager.shared.ensureOfferingsLoaded()
                        }
                    }

                    Text(selectedPlan == "Annuel"
                         ? "3 jours gratuits, puis \(annualPrice) automatiquement renouvelé chaque année.\nRésiliation possible à tout moment dans Réglages > Abonnements.\nLe paiement sera débité de votre compte Apple à la fin de l'essai."
                         : "Abonnement mensuel à \(monthlyPrice), renouvelé automatiquement chaque mois.\nRésiliation possible à tout moment dans Réglages > Abonnements.\nLe paiement sera débité de votre compte Apple.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        
                    Button("Restaurer mes achats") {
                        Task {
                            await SubscriptionManager.shared.restorePurchases()
                            if SubscriptionManager.shared.isProEntitled {
                                HapticManager.notification(.success)
                                withAnimation { showingPaymentSuccess = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onComplete() }
                            }
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .underline()

                    HStack(spacing: 16) {
                        Button("Confidentialité") { showPrivacyPolicy = true }
                        Text("·").foregroundColor(.white.opacity(0.3))
                        Button("Conditions d'utilisation (EULA)") { showTerms = true }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(
                    LinearGradient(
                        colors: [Color.deepCharcoal.opacity(0), Color.deepCharcoal],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Une erreur inconnue est survenue.")
            }

            // Payment Success Overlay
            if showingPaymentSuccess {
                paymentSuccessOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(100)
            }
        }
        .animation(.spring(), value: showingPaymentSuccess)
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://magnificent-crostata-3fa347.netlify.app/privacypolicy")!)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showTerms) {
            SafariView(url: URL(string: "https://magnificent-crostata-3fa347.netlify.app/termsandconditions")!)
                .ignoresSafeArea()
        }
    }

    // MARK: - Payment Success Overlay
    private var paymentSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture {} // block taps

            VStack(spacing: 24) {
                // Celebration Lottie confetti burst
                LottieView(animationName: "celebration", loopMode: .playOnce, animationSpeed: 1.0)
                    .frame(width: 200, height: 200)

                Text("Bienvenue !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)

                Text("Votre compte GoPilates Premium est activé.\nPrête à transformer votre corps ?")
                    .font(.system(size: 15))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)

                GoldButton(title: "Commencer mon parcours") {
                    onComplete()
                }
                .padding(.horizontal, 24)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.champagneBlush)
                    .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
            )
            .padding(.horizontal, 32)
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.metallicGold.opacity(0.2), Color.metallicGold.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.metallicGold)
            }
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PremiumPriceCard: View {
    let title: String
    let subtitle: String
    var badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 16) {
                    // Radio
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.metallicGold : Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        if isSelected {
                            Circle()
                                .fill(Color.metallicGold)
                                .frame(width: 12, height: 12)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.metallicGold.opacity(0.1) : Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.metallicGold : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                )

                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.metallicGold))
                        .shadow(color: Color.metallicGold.opacity(0.3), radius: 8, y: 4)
                        .offset(x: -16, y: -12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingPaywallView(onBack: {}, onComplete: {})
        .environment(OnboardingData())
}
