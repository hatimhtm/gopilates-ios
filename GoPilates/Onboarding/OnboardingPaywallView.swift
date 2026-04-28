import SwiftUI
import RevenueCat
import SafariServices
import StoreKit
import UIKit

struct OnboardingPaywallView: View {
    @Environment(OnboardingData.self) var data
    var onBack: () -> Void
    var onComplete: () -> Void

    @State private var currentSlide: Int = 0
    @State private var isPurchasing = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var reminderEnabled: Bool = true
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showingPaymentSuccess = false
    @State private var hasFinalized = false

    // Trial timeline dates (computed lazily so they reflect "today")
    private var trialStartDate: Date { Date() }
    private var trialReminderDate: Date {
        Calendar.current.date(byAdding: .day, value: 2, to: trialStartDate) ?? trialStartDate
    }
    private var trialEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 3, to: trialStartDate) ?? trialStartDate
    }

    private var shortDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "dd MMM"
        return f
    }

    private var annualPrice: String? {
        guard let offering = SubscriptionManager.shared.currentOffering,
              let package = offering.availablePackages.first(where: { $0.packageType == .annual }) else {
            return nil
        }
        return package.localizedPriceString
    }

    private var priceLine: String {
        if let price = annualPrice {
            return "Facturé annuellement à \(price)/an"
        }
        return "Chargement…"
    }

    private var offeringsLoaded: Bool {
        SubscriptionManager.shared.currentOffering != nil
    }

    var body: some View {
        // Explicit read so SwiftUI's @Observable tracking registers this property.
        // Promo-code redemptions and restores flip isProEntitled asynchronously, and
        // we rely on .onChange below to finalize onboarding when that happens.
        let isEntitled = SubscriptionManager.shared.isProEntitled

        return ZStack {
            OnboardingBackground()

            VStack(spacing: 0) {
                // Header (close button)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepCharcoal.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                // Slides
                TabView(selection: $currentSlide) {
                    PaywallSlide1View(onContinue: { advance(to: 1) })
                        .tag(0)
                    PaywallSlide2View(onContinue: { advance(to: 2) })
                        .tag(1)
                    PaywallSlide3View(
                        reminderEnabled: $reminderEnabled,
                        trialReminderDate: trialReminderDate,
                        trialEndDate: trialEndDate,
                        dateFormatter: shortDateFormatter,
                        priceLine: priceLine,
                        offeringsLoaded: offeringsLoaded,
                        isPurchasing: isPurchasing,
                        onSubscribe: handleSubscribe,
                        onRestore: handleRestore,
                        onPromoCode: handlePromoCode,
                        onShowTerms: { showTerms = true },
                        onShowPrivacy: { showPrivacyPolicy = true }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom page dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(currentSlide == i ? Color.deepCharcoal : Color.deepCharcoal.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentSlide)
                    }
                }
                .padding(.bottom, 16)
            }

            if showingPaymentSuccess {
                paymentSuccessOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(100)
            }
        }
        .animation(.spring(), value: showingPaymentSuccess)
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Une erreur inconnue est survenue.")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            if let url = URL(string: "https://magnificent-crostata-3fa347.netlify.app/privacypolicy") {
                SafariView(url: url).ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showTerms) {
            if let url = URL(string: "https://magnificent-crostata-3fa347.netlify.app/termsandconditions") {
                SafariView(url: url).ignoresSafeArea()
            }
        }
        .onAppear {
            Task { await SubscriptionManager.shared.ensureOfferingsLoaded() }
        }
        .onChange(of: isEntitled) { _, newValue in
            if newValue && !hasFinalized {
                handleEntitlementGranted()
            }
        }
    }

    private func advance(to index: Int) {
        HapticManager.impact(.medium)
        withAnimation(.easeInOut(duration: 0.35)) {
            currentSlide = index
        }
    }

    private func handleSubscribe() {
        Task {
            if SubscriptionManager.shared.currentOffering == nil {
                await SubscriptionManager.shared.ensureOfferingsLoaded()
            }

            guard let offering = SubscriptionManager.shared.currentOffering else {
                errorMessage = "Les forfaits ne sont pas encore chargés. Veuillez patienter un instant ou vérifier votre connexion internet."
                showError = true
                return
            }

            guard let package = offering.availablePackages.first(where: { $0.packageType == .annual }) else {
                errorMessage = "Forfait introuvable. Veuillez réessayer plus tard."
                showError = true
                return
            }

            isPurchasing = true

            do {
                let success = try await SubscriptionManager.shared.purchase(package: package)
                isPurchasing = false
                if success {
                    if reminderEnabled {
                        await NotificationManager.shared.scheduleTrialEndReminder()
                    } else {
                        NotificationManager.shared.cancelTrialEndReminder()
                    }
                    handleEntitlementGranted()
                }
            } catch {
                isPurchasing = false
                let nsError = error as NSError
                if nsError.code == 1 /* purchaseCancelledError */ {
                    // User cancelled — silent
                } else if nsError.code == 7 /* productAlreadyPurchasedError */ {
                    await SubscriptionManager.shared.restorePurchases()
                    if SubscriptionManager.shared.isProEntitled {
                        handleEntitlementGranted()
                    }
                } else {
                    errorMessage = "L'achat a échoué. Veuillez vérifier votre connexion internet et réessayer."
                    showError = true
                }
            }
        }
    }

    private func handleRestore() {
        Task {
            await SubscriptionManager.shared.restorePurchases()
            if SubscriptionManager.shared.isProEntitled {
                handleEntitlementGranted()
            }
        }
    }

    /// Presents Apple's native offer code redemption sheet (StoreKit 2). Since Apple's
    /// March 26, 2026 unification, this single sheet handles offer codes for all IAP
    /// types — auto-renewable subscriptions, non-consumables, consumables, and
    /// non-renewing subscriptions. RevenueCat's transaction observer picks up the
    /// redemption automatically and flips `isProEntitled`; the backup refresh after the
    /// sheet dismisses covers the rare case the observer doesn't fire.
    private func handlePromoCode() {
        Task { @MainActor in
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else {
                return
            }
            do {
                try await AppStore.presentOfferCodeRedeemSheet(in: scene)
            } catch {
                // Sheet dismissed or unavailable — Apple handles its own UX
            }
            await SubscriptionManager.shared.refreshCustomerInfo()
        }
    }

    private func handleEntitlementGranted() {
        guard !hasFinalized else { return }
        hasFinalized = true
        HapticManager.notification(.success)
        withAnimation { showingPaymentSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onComplete() }
    }

    // MARK: - Payment Success Overlay

    private var paymentSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 24) {
                LottieView(animationName: "celebration", loopMode: .playOnce, animationSpeed: 1.0)
                    .frame(width: 200, height: 200)

                Text("Bienvenue !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)

                Text("Votre compte GoPilates Premium est activé.\nPrête à transformer votre corps ?")
                    .font(.system(size: 15))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
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

// MARK: - Slide 1 (Premium intro)

private struct PaywallSlide1View: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Nous vous offrons trois jours\nd'accès premium, seulement pour vous")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.deepCharcoal)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer().frame(height: 48)

            CardsIllustrationView()
                .frame(width: 240, height: 200)

            Spacer()

            VStack(spacing: 12) {
                PaywallPrimaryButton(title: "En profiter", isLoading: false, isEnabled: true, action: onContinue)
                    .padding(.horizontal, 24)

                Text("Sans engagement. Annulation libre.")
                    .font(.system(size: 13))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Slide 2 (Reminder reassurance)

private struct PaywallSlide2View: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("Nous vous enverrons\nun rappel 1 jour avant\nla fin de votre essai")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)

                Text("Pas de surprises, pas de pression")
                    .font(.system(size: 15))
                    .foregroundColor(.deepCharcoal.opacity(0.55))
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 48)

            BellWithBadgeView()
                .frame(width: 140, height: 140)

            Spacer()

            VStack(spacing: 12) {
                PaywallPrimaryButton(title: "Essayer pour 0,00€", isLoading: false, isEnabled: true, action: onContinue)
                    .padding(.horizontal, 24)

                Text("Sans engagement. Annulation libre.")
                    .font(.system(size: 13))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Slide 3 (Trial timeline + subscribe)

private struct PaywallSlide3View: View {
    @Binding var reminderEnabled: Bool
    let trialReminderDate: Date
    let trialEndDate: Date
    let dateFormatter: DateFormatter
    let priceLine: String
    let offeringsLoaded: Bool
    let isPurchasing: Bool
    let onSubscribe: () -> Void
    let onRestore: () -> Void
    let onPromoCode: () -> Void
    let onShowTerms: () -> Void
    let onShowPrivacy: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Comment fonctionne\nl'essai gratuit ?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "2BB673"))
                    Text("Aucun frais ne vous sera facturé aujourd'hui")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "2BB673"))
                }
                .padding(.horizontal, 16)

                // Timeline
                VStack(spacing: 0) {
                    TrialTimelineRow(
                        icon: "checkmark",
                        iconBackground: Color(hex: "2BB673"),
                        title: "Installez l'appli",
                        subtitle: "Paramétrez-la pour vos objectifs",
                        showsConnector: true
                    )
                    TrialTimelineRow(
                        icon: "lock.open.fill",
                        iconBackground: Color(hex: "2BB673"),
                        title: "Aujourd'hui - Début de l'essai",
                        subtitle: "Entièrement gratuit pendant vos 3 premiers jours",
                        showsConnector: true
                    )
                    TrialTimelineRow(
                        icon: "bell.fill",
                        iconBackground: Color(hex: "F2A65A"),
                        title: "\(dateFormatter.string(from: trialReminderDate)) - Rappel",
                        subtitle: "Lorsque votre essai prendra fin",
                        showsConnector: true
                    )
                    TrialTimelineRow(
                        icon: "star.fill",
                        iconBackground: Color.vintagePink,
                        title: "\(dateFormatter.string(from: trialEndDate)) - Devenir membre",
                        subtitle: "Votre essai prendra fin sauf si vous l'annulez",
                        showsConnector: false
                    )
                }
                .padding(.horizontal, 24)

                // Reminder toggle
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.deepCharcoal.opacity(0.6))
                    Text("Rappel avant la fin de l'essai")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.deepCharcoal)
                    Spacer()
                    Toggle("", isOn: $reminderEnabled)
                        .labelsHidden()
                        .tint(Color.vintagePink)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.7))
                )
                .padding(.horizontal, 24)

                // Subscribe button
                VStack(spacing: 8) {
                    PaywallPrimaryButton(
                        title: "Commencer essai gratuit",
                        isLoading: isPurchasing || !offeringsLoaded,
                        isEnabled: !isPurchasing,
                        action: onSubscribe
                    )
                    .padding(.horizontal, 24)

                    Text(priceLine)
                        .font(.system(size: 13))
                        .foregroundColor(.deepCharcoal.opacity(0.55))
                        .multilineTextAlignment(.center)
                }

                // Footer links
                HStack(spacing: 0) {
                    PaywallFooterLink(title: "Restaurer", action: onRestore)
                    PaywallFooterDivider()
                    PaywallFooterLink(title: "Code promo", action: onPromoCode)
                    PaywallFooterDivider()
                    PaywallFooterLink(title: "Conditions", action: onShowTerms)
                    PaywallFooterDivider()
                    PaywallFooterLink(title: "Confidentialité", action: onShowPrivacy)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Reusable components

private struct PaywallPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color.vintagePink, Color.nudeModern],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.vintagePink.opacity(0.35), radius: 12, y: 6)
            .opacity(isEnabled ? 1.0 : 0.7)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

private struct TrialTimelineRow: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let subtitle: String
    let showsConnector: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(iconBackground.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(iconBackground)
                }

                if showsConnector {
                    Rectangle()
                        .fill(Color.deepCharcoal.opacity(0.12))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.deepCharcoal.opacity(0.55))
            }
            .padding(.bottom, showsConnector ? 18 : 0)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaywallFooterLink: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.55))
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct PaywallFooterDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.deepCharcoal.opacity(0.2))
            .frame(width: 1, height: 12)
    }
}

// MARK: - Custom Illustrations

private struct CardsIllustrationView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 200, height: 200)

            // Left card (rotated -12°)
            IllustrationCard(symbol: "quote.bubble.fill", tint: Color.deepCharcoal.opacity(0.4))
                .rotationEffect(.degrees(-12))
                .offset(x: -52, y: 8)

            // Right card (rotated +12°)
            IllustrationCard(symbol: "heart.fill", tint: Color.vintagePink)
                .rotationEffect(.degrees(12))
                .offset(x: 52, y: 8)

            // Center card (front)
            IllustrationCard(symbol: "sparkles", tint: Color.vintagePink)
        }
    }
}

private struct IllustrationCard: View {
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(tint)
                .padding(.top, 14)
            Capsule().fill(tint.opacity(0.25)).frame(width: 38, height: 4)
            Capsule().fill(tint.opacity(0.15)).frame(width: 28, height: 4)
            Spacer()
        }
        .frame(width: 70, height: 96)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        )
    }
}

private struct BellWithBadgeView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell.fill")
                .font(.system(size: 96, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD166"), Color(hex: "F2A65A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "F2A65A").opacity(0.35), radius: 16, y: 8)

            Text("1")
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Color(hex: "E5363B")))
                .offset(x: 6, y: -4)
        }
    }
}

#Preview {
    OnboardingPaywallView(onBack: {}, onComplete: {})
        .environment(OnboardingData())
}
