import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - Dashboard View (Main Tab Bar)

struct DashboardView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(userProfile)
                .tabItem {
                    Label("Accueil", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            VODLibraryView()
                .environmentObject(userProfile)
                .tabItem {
                    Label("Explorer", systemImage: "play.square.stack")
                }
                .tag(1)

            StreakCalendarView()
                .environmentObject(userProfile)
                .tabItem {
                    Label("Calendrier", systemImage: selectedTab == 2 ? "calendar.badge.checkmark" : "calendar")
                }
                .tag(2)

            ProfileView()
                .environmentObject(userProfile)
                .tabItem {
                    Label("Profil", systemImage: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                }
                .tag(3)
        }
        .accentColor(Color.metallicGold)
        .onAppear {
            configureTabBarAppearance()
            HealthKitManager.shared.requestAuthorization()
        }
        .overlay(
            Group {
                if let badge = userProfile.newlyUnlockedBadge {
                    BadgeCelebrationView(badge: badge) {
                        userProfile.newlyUnlockedBadge = nil
                    }
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(100)
                }
            }
        )
        .animation(.spring(), value: userProfile.newlyUnlockedBadge)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // champagneBlush with slight opacity
        appearance.backgroundColor = UIColor(
            red: 253.0 / 255.0,
            green: 226.0 / 255.0,
            blue: 219.0 / 255.0,
            alpha: 0.95
        )

        // Selected item color
        let goldColor = UIColor(
            red: 221.0 / 255.0,
            green: 178.0 / 255.0,
            blue: 99.0 / 255.0,
            alpha: 1.0
        )
        appearance.stackedLayoutAppearance.selected.iconColor = goldColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: goldColor]

        // Unselected item color
        let charcoalColor = UIColor(
            red: 58.0 / 255.0,
            green: 42.0 / 255.0,
            blue: 47.0 / 255.0,
            alpha: 0.5
        )
        appearance.stackedLayoutAppearance.normal.iconColor = charcoalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: charcoalColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Global Badge Celebration Overlay
struct BadgeCelebrationView: View {
    let badge: Badge
    var onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            LottieView(animationName: "celebration", loopMode: .playOnce, animationSpeed: 1.0)
                .frame(width: 300, height: 300)
                .allowsHitTesting(false)
            
            VStack(spacing: 24) {
                Image(systemName: badge.icon)
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: badge.colorHex))
                    .padding(30)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color(hex: badge.colorHex).opacity(0.5), radius: 20, y: 10)
                    .scaleEffect(appear ? 1 : 0.4)
                    .rotationEffect(.degrees(appear ? 0 : -20))

                Text("Nouveau Badge Déverrouillé !")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)

                Text(badge.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: badge.colorHex))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Button(action: {
                    withAnimation { onDismiss() }
                }) {
                    Text("Super !")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white))
                }
                .opacity(appear ? 1 : 0)
                .padding(.top, 16)
            }
        }
        .onAppear {
            HapticManager.notification(.success)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                appear = true
            }
        }
    }
}
