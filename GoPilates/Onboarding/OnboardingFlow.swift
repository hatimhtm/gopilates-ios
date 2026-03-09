import SwiftUI

struct OnboardingFlow: View {
    @State private var data = OnboardingData()
    @EnvironmentObject var userProfile: UserProfile
    @State private var currentScreen: Int = 0
    @State private var goForward: Bool = true

    private let totalScreens = 40 // 0-39 inclusive (added name screen)

    private var showTopBar: Bool {
        return currentScreen < 37 || currentScreen == 38
    }

    var body: some View {
        ZStack {
            OnboardingBackground()
            
            VStack(spacing: 0) {
                if showTopBar {
                    OnboardingProgressBar(current: currentScreen, total: 38)
                        .padding(.top, 8)
                        
                    if currentScreen > 0 {
                        HStack {
                            OnboardingBackButton(action: goBack)
                            Spacer()
                        }
                        .padding(.leading, 12)
                        .padding(.top, 4)
                    } else {
                        Spacer().frame(height: 16)
                    }
                }
                
                screenView
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: goForward ? .trailing : .leading),
                            removal: .move(edge: goForward ? .leading : .trailing)
                        )
                    )
                    .id(currentScreen)
            }
        }
        .environment(data)
        .animation(.easeInOut(duration: 0.35), value: currentScreen)
    }

    private func goNext() {
        goForward = true
        withAnimation(.easeInOut(duration: 0.35)) {
            currentScreen = min(currentScreen + 1, totalScreens - 1)
        }
    }

    private func goBack() {
        goForward = false
        withAnimation(.easeInOut(duration: 0.35)) {
            if currentScreen == 38 {
                currentScreen = 36
            } else {
                currentScreen = max(currentScreen - 1, 0)
            }
        }
    }

    /// Copy all onboarding data into the persistent UserProfile
    private func finalizeOnboarding() {
        userProfile.name = data.userName.isEmpty ? "Utilisatrice" : data.userName
        userProfile.heightCm = data.heightCm
        userProfile.currentWeightKg = data.currentWeightKg
        userProfile.targetWeightKg = data.targetWeightKg
        userProfile.age = data.age
        userProfile.fitnessLevel = data.fitnessLevel.isEmpty ? "Débutante" : data.fitnessLevel
        // Persist injury selections so workout filters can use them
        userProfile.injuries = data.injuries
        userProfile.hasCompletedOnboarding = true
    }

    private var screenView: AnyView {
        switch currentScreen {
        case 0:
            return AnyView(OnboardingGreetingView(onNext: goNext))
        case 1:
            return AnyView(OnboardingNameView(onNext: goNext, onBack: goBack))
        case 2:
            return AnyView(OnboardingMotivationView(onNext: goNext, onBack: goBack))
        case 3:
            return AnyView(OnboardingFamiliarityView(onNext: goNext, onBack: goBack))
        case 4:
            return AnyView(OnboardingGoalView(onNext: goNext, onBack: goBack))
        case 5:
            return AnyView(OnboardingBodyZoneView(onNext: goNext, onBack: goBack))
        case 6:
            return AnyView(OnboardingHeightView(onNext: goNext, onBack: goBack))
        case 7:
            return AnyView(OnboardingCurrentWeightView(onNext: goNext, onBack: goBack))
        case 8:
            return AnyView(OnboardingTargetWeightView(onNext: goNext, onBack: goBack))
        case 9:
            return AnyView(OnboardingFuturePacingView(onNext: goNext, onBack: goBack))
        case 10:
            return AnyView(OnboardingBodyTypeCurrentView(onNext: goNext, onBack: goBack))
        case 11:
            return AnyView(OnboardingBodyTypeTargetView(onNext: goNext, onBack: goBack))
        case 12:
            return AnyView(OnboardingWeightProjectionView(onNext: goNext, onBack: goBack))
        case 13:
            return AnyView(OnboardingAgeView(onNext: goNext, onBack: goBack))
        case 14:
            return AnyView(OnboardingPotentialView(onNext: goNext, onBack: goBack))
        case 15:
            return AnyView(OnboardingLocationView(onNext: goNext, onBack: goBack))
        case 16:
            return AnyView(OnboardingTrainingTypeView(onNext: goNext, onBack: goBack))
        case 17:
            return AnyView(OnboardingDifficultyView(onNext: goNext, onBack: goBack))
        case 18:
            return AnyView(OnboardingInjuriesView(onNext: goNext, onBack: goBack))
        case 19:
            return AnyView(OnboardingMiniFuturePaceView(onNext: goNext, onBack: goBack))
        case 20:
            return AnyView(OnboardingDailyLifeView(onNext: goNext, onBack: goBack))
        case 21:
            return AnyView(OnboardingActivityLevelView(onNext: goNext, onBack: goBack))
        case 22:
            return AnyView(OnboardingFitnessLevelView(onNext: goNext, onBack: goBack))
        case 23:
            return AnyView(OnboardingSocialProofMidView(onNext: goNext, onBack: goBack))
        case 24:
            return AnyView(OnboardingFlexibilityView(onNext: goNext, onBack: goBack))
        case 25:
            return AnyView(OnboardingCardioView(onNext: goNext, onBack: goBack))
        case 26:
            return AnyView(OnboardingAffirmation1View(onNext: goNext, onBack: goBack))
        case 27:
            return AnyView(OnboardingAffirmation2View(onNext: goNext, onBack: goBack))
        case 28:
            return AnyView(OnboardingAffirmation3View(onNext: goNext, onBack: goBack))
        case 29:
            return AnyView(OnboardingAffirmation4View(onNext: goNext, onBack: goBack))
        case 30:
            return AnyView(OnboardingSocialProof100kView(onNext: goNext, onBack: goBack))
        case 31:
            return AnyView(OnboardingRewardView(onNext: goNext, onBack: goBack))
        case 32:
            return AnyView(OnboardingEmotionalGoalsView(onNext: goNext, onBack: goBack))
        case 33:
            return AnyView(OnboardingFaceTransformView(onNext: goNext, onBack: goBack))
        case 34:
            return AnyView(OnboardingFullScreenQ1View(onNext: goNext, onBack: goBack))
        case 35:
            return AnyView(OnboardingFullScreenQ2View(onNext: goNext, onBack: goBack))
        case 36:
            return AnyView(OnboardingFullScreenQ3View(onNext: goNext, onBack: goBack))
        case 37:
            return AnyView(OnboardingFacadingView(onNext: goNext))
        case 38:
            return AnyView(OnboardingFinalProjectionView(onNext: goNext, onBack: goBack))
        case 39:
            return AnyView(OnboardingPaywallView(onBack: goBack, onComplete: finalizeOnboarding))
        default:
            return AnyView(EmptyView())
        }
    }
}
