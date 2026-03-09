# Task Manager Agent Memory

## Project: GoPilates iOS App
- Entry point: `GoPilates/App/GoPilatesApp.swift`
- XcodeGen project spec: `project.yml` in project root
- Regenerate xcodeproj: `cd "/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp" && xcodegen generate`
- iOS 15 deployment target, Swift 5.9, Xcode 15.2
- All source under `GoPilates/` folder
- ExerciseCatalog is inside `GoPilates/Models/Exercise.swift` (not a separate file)

## Key Patterns & Lessons

### SwiftUI @ViewBuilder switch with many cases causes blank screen
- A `@ViewBuilder` switch with 39+ cases creates an astronomically large nested `_ConditionalContent` type
- The app compiles fine but the SwiftUI runtime hangs trying to resolve the view type at launch
- Symptom: app runs (no crash) but never renders past the launch screen
- Fix: return `AnyView` from each case to erase the type complexity
- File fixed: `GoPilates/Onboarding/OnboardingFlow.swift` - changed `screenView` from `@ViewBuilder some View` to `AnyView`

### SF Symbols availability
- Many `figure.*` activity symbols (figure.pilates, figure.core.training, figure.mind.and.body, figure.arms.open) require iOS 16+
- App targets iOS 15 -- these symbols render as blank but do NOT crash
- Not the root cause of the blank screen issue, but worth noting for UI polish

### Debugging iOS simulator blank screen
- Use `xcrun simctl io <UDID> screenshot /tmp/screenshot.png` to capture simulator state
- Use `xcrun simctl spawn <UDID> log show --predicate 'process == "GoPilates"' --last 15s --style compact` for logs
- A running process (no crash) that shows only the launch screen = SwiftUI body not rendering
