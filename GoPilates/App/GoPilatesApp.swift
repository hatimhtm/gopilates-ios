import SwiftUI
import AVFoundation
import RevenueCat

@main
struct GoPilatesApp: App {
    @StateObject private var userProfile = UserProfile()

    init() {
        // Ensure audio plays even if the hardware silent switch is on
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }

        // RevenueCat Configuration
        SubscriptionManager.shared.configure(withAPIKey: "sk_dyGAndpwJolSnYvldWYocukvCnDds")
    }

    var body: some Scene {
        WindowGroup {
            if userProfile.hasCompletedOnboarding {
                DashboardView()
                    .environmentObject(userProfile)
            } else {
                OnboardingFlow()
                    .environmentObject(userProfile)
            }
        }
    }
}
