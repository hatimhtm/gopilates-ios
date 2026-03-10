import SwiftUI
import UserNotifications
import SafariServices

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var showAbout = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var appear = false
    @State private var animatedSessions: Int = 0
    @State private var animatedStreak: Int = 0
    @State private var animatedMinutes: Int = 0
    @State private var goldRingPulse = false
    @State private var showCustomerCenter = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.champagneBlush.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        avatarHeader
                        statsCards
                        weightProgressCard
                        achievementsSection
                        settingsSection
                        versionLabel
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appear = true }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) { goldRingPulse = true }
                animateProfileCounters()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Avatar Header

    private var avatarHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                // Gold ring pulse using scaleEffect to prevent layout jitter
                Circle()
                    .stroke(Color.metallicGold.opacity(goldRingPulse ? 0.4 : 0.1), lineWidth: 2)
                    .frame(width: 88, height: 88)
                    .scaleEffect(goldRingPulse ? 96.0/88.0 : 1.0)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.vintagePink.opacity(0.6), Color.vintagePink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.vintagePink.opacity(0.3), radius: 10, y: 5)

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .frame(width: 96, height: 96)

            Text("Bonjour, \(userProfile.name)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.deepCharcoal)

            Text("Niveau : \(userProfile.fitnessLevel)")
                .font(.system(size: 14))
                .foregroundColor(.deepCharcoal.opacity(0.6))
        }
        .padding(.top, 16)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 24)
    }

    // MARK: - Stats Cards

    private var statsCards: some View {
        HStack(spacing: 12) {
            statCard(
                value: "\(animatedSessions)",
                label: "Séances",
                icon: "figure.pilates",
                color: "DDB263"
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appear)

            statCard(
                value: "\(animatedStreak)",
                label: "Jours streak",
                icon: "flame.fill",
                color: "E8B6C3"
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: appear)

            statCard(
                value: "\(animatedMinutes)",
                label: "Min actives",
                icon: "clock.fill",
                color: "E6C7B2"
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: appear)
        }
    }

    private func statCard(value: String, label: String, icon: String, color: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.deepCharcoal)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.deepCharcoal.opacity(0.6))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }

    // MARK: - Weight Progress Card

    private var weightProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Objectif poids")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.deepCharcoal)
                Spacer()
                Text("IMC: \(String(format: "%.1f", userProfile.bmi))")
                    .font(.system(size: 13))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
            }

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Actuel")
                        .font(.system(size: 11))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                    Text("\(String(format: "%.1f", userProfile.currentWeightKg)) kg")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                }

                Spacer()

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.nudeModern.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.vintagePink, Color.metallicGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * userProfile.progressPercent, height: 8)
                            .animation(.easeInOut, value: userProfile.progressPercent)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 16)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Objectif")
                        .font(.system(size: 11))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                    Text("\(String(format: "%.1f", userProfile.targetWeightKg)) kg")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.metallicGold)
                }
            }

            if userProfile.weightToLose > 0 {
                Text("\(String(format: "%.1f", userProfile.weightToLose)) kg restants")
                    .font(.system(size: 12))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
            } else {
                Text("Objectif atteint !")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.metallicGold)
            }
        }
        .padding(16)
        .glassCard()
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Récompenses")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Badge.allCases) { badge in
                    badgeCard(badge)
                }
            }
        }
    }

    private func badgeCard(_ badge: Badge) -> some View {
        let isEarned = userProfile.earnedBadges.contains(badge)

        return VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.system(size: 28))
                .foregroundColor(isEarned ? Color(hex: badge.colorHex) : .gray.opacity(0.3))

            Text(badge.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isEarned ? .deepCharcoal : .gray.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEarned ? Color.white.opacity(0.8) : Color.white.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isEarned ? Color(hex: badge.colorHex).opacity(0.4) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isEarned ? Color(hex: badge.colorHex).opacity(0.15) : .clear,
            radius: 8, y: 4
        )
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Text("Réglages")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepCharcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                settingsToggle(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: Binding(
                        get: { userProfile.notificationsEnabled },
                        set: { newValue in
                            NotificationManager.shared.toggleNotifications(enabled: newValue) { granted in
                                userProfile.notificationsEnabled = granted
                            }
                        }
                    )
                )

                Divider()
                    .padding(.horizontal, 16)

                settingsToggle(
                    icon: "speaker.wave.2.fill",
                    title: "Son & coaching vocal",
                    isOn: $userProfile.voiceCoachingEnabled
                )

                Divider()
                    .padding(.horizontal, 16)

                Button(action: { showCustomerCenter = true }) {
                    settingsRow(icon: "star.fill", title: "Gérer l'abonnement")
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.horizontal, 16)

                Button(action: { showAbout = true }) {
                    settingsRow(icon: "info.circle.fill", title: "À propos de GoPilates")
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.horizontal, 16)

                Button(action: { showPrivacyPolicy = true }) {
                    settingsRow(icon: "lock.shield.fill", title: "Politique de confidentialité")
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.horizontal, 16)

                Button(action: { showTerms = true }) {
                    settingsRow(icon: "doc.text.fill", title: "Conditions d'utilisation")
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
        }
        .sheet(isPresented: $showAbout) {
            aboutSheet
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://magnificent-crostata-3fa347.netlify.app/privacypolicy")!)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showTerms) {
            SafariView(url: URL(string: "https://magnificent-crostata-3fa347.netlify.app/termsandconditions")!)
                .ignoresSafeArea()
        }
        .presentCustomerCenter(isPresented: $showCustomerCenter, onDismiss: {
            showCustomerCenter = false
        })
    }

    // MARK: - About Sheet
    private var aboutSheet: some View {
        ZStack {
            Color.champagneBlush.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "figure.pilates")
                    .font(.system(size: 60))
                    .foregroundColor(.vintagePink)
                
                Text("GoPilates")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                
                Text("Version 1.0")
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.5))
                
                Text("GoPilates n'est pas qu'une simple application d'entraînement. C'est votre studio de Pilates personnel, disponible 24h/24 et 7j/7.\n\nNotre mission est de rendre la méthode Pilates accessible à toutes les femmes, quel que soit leur niveau.\n\nChaque mouvement est conçu pour renforcer votre centre, allonger vos muscles et apaiser votre esprit. Grâce à nos programmes sur-mesure, vous construisez un corps plus fort et plus équilibré, en douceur mais avec efficacité.\n\nRespirez. Engagez. Transformez.")
                    .font(.system(size: 15))
                    .foregroundColor(.deepCharcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                Text("© 2026 ViralFactory")
                    .font(.system(size: 12))
                    .foregroundColor(.deepCharcoal.opacity(0.3))
                    .padding(.bottom, 30)
            }
        }
    }

    private func settingsToggle(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.vintagePink)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.metallicGold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.vintagePink)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.deepCharcoal.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Version

    private var versionLabel: some View {
        Text("GoPilates v1.0")
            .font(.system(size: 12))
            .foregroundColor(.deepCharcoal.opacity(0.3))
            .padding(.top, 8)
    }

    // MARK: - Animated Counter Helper

    private func animateProfileCounters() {
        let targetSessions = userProfile.totalSessions
        let targetStreak   = userProfile.currentStreak
        let targetMinutes  = userProfile.totalMinutes

        let steps = 20
        let interval = 0.04

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                animatedSessions = Int(Double(targetSessions) * Double(i) / Double(steps))
                animatedStreak   = Int(Double(targetStreak)   * Double(i) / Double(steps))
                animatedMinutes  = Int(Double(targetMinutes)  * Double(i) / Double(steps))
            }
        }
    }
}

// MARK: - Safari In-App Browser

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
