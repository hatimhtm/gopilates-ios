import SwiftUI

// MARK: - Home View (Main Feed)
struct HomeView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var selectedFilter: ExerciseCategory? = nil
    @Namespace private var animation

    // MARK: - Duration helper (smart format)
    private func durationLabel(_ seconds: Int) -> String {
        if seconds >= 60 { return "\(seconds / 60) min" }
        return "\(seconds)s"
    }
    
    private var featuredWorkout: PilatesExercise {
        let dayIndex = userProfile.challengeDayCompleted
        let exercises = ExerciseCatalog.all30DayChallenge
        return exercises[min(dayIndex, exercises.count - 1)]
    }
    
    private var filteredExercises: [PilatesExercise] {
        let exercises = ExerciseCatalog.vod
        if let filter = selectedFilter {
            return exercises.filter { $0.category == filter }
        }
        return exercises
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    private let dayLabels = ["L", "M", "M", "J", "V", "S", "D"]

    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                LinearGradient(
                    colors: [Color.nudeModern.opacity(0.3), Color.champagneBlush, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        
                        // 🔥 30-DAY CHALLENGE = THE BIG CENTERPIECE
                        challengeHeroCard
                        
                        // Daily session — smaller card below
                        dailySessionCard
                        
                        thisWeekCard
                        statsRow
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Programmes courts")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepCharcoal)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            collectionsFeed
                                .padding(.bottom, 16)
                            
                            HStack {
                                Text("Exercices")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.deepCharcoal)
                                Spacer()
                                Text("\(filteredExercises.count)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.vintagePink)
                            }
                            .padding(.horizontal, 24)
                            
                            categoryFilters
                            workoutGrid
                        }
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(getGreeting())
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
                
                Text(userProfile.name.isEmpty || userProfile.name == "Utilisatrice" ? "Bienvenue" : userProfile.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Streak Badge with glow
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.vintagePink)
                    .font(.system(size: 14))
                Text("\(userProfile.currentStreak)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepCharcoal)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassCard()
        }
        .padding(.horizontal, 24)
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Bonjour," }
        if hour < 18 { return "Bon après-midi," }
        return "Bonsoir,"
    }
    
    // MARK: - 30-Day Challenge HERO (Big, flashy centerpiece)
    private var challengeHeroCard: some View {
        NavigationLink(destination: ChallengeView()) {
            ZStack(alignment: .bottomLeading) {
                // Large gradient background
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.vintagePink.opacity(0.7),
                                Color.metallicGold.opacity(0.5),
                                Color.deepCharcoal.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 240)
                    .overlay(
                        Image(systemName: "flame.fill")
                            .font(.system(size: 120, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.08))
                            .offset(x: 90, y: -30)
                    )
                    .clipped()
                
                // Dark gradient at bottom
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 240)
                .cornerRadius(28)
                
                // Play Button
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48, height: 48)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                            .overlay(
                                Image(systemName: "play.fill")
                                    .foregroundColor(.vintagePink)
                                    .font(.system(size: 20))
                                    .offset(x: 2)
                            )
                    }
                    Spacer()
                }
                .padding(20)
                
                // Progress ring in top-left
                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 3)
                                .frame(width: 44, height: 44)
                            
                            Circle()
                                .trim(from: 0, to: userProfile.challengeProgressPercent)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 44, height: 44)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(userProfile.challengeDayCompleted)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(20)

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("DÉFI 30 JOURS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                    
                    Text(userProfile.challengeDayCompleted == 0
                         ? "Commencez votre\ntransformation"
                         : "Jour \(userProfile.challengeDayCompleted + 1)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(featuredWorkout.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(durationLabel(featuredWorkout.duration))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12))
                            let remaining = max(0, 30 - userProfile.challengeDayCompleted)
                            Text("\(remaining) jours restants")
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(20)
            }
            .padding(.horizontal, 24)
            .shadow(color: Color.vintagePink.opacity(0.15), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Daily Session (Smaller card)
    private var dailySessionCard: some View {
        NavigationLink(destination: ExerciseDetailView(exercise: featuredWorkout)) {
            HStack(spacing: 16) {
                // Exercise icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.nudeModern.opacity(0.3), Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: featuredWorkout.sfSymbol)
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundColor(.deepCharcoal.opacity(0.4))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Séance du jour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.deepCharcoal.opacity(0.5))
                    
                    Text(featuredWorkout.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(durationLabel(featuredWorkout.duration))
                                .font(.system(size: 10))
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.metallicGold)
                            Text(featuredWorkout.difficulty.rawValue)
                                .font(.system(size: 10))
                        }
                    }
                    .foregroundColor(.deepCharcoal.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.vintagePink.opacity(0.5))
            }
            .padding(16)
            .glassCard()
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - This Week Calendar (Interactive)
    private var thisWeekCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Cette Semaine")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                Spacer()
                
                let weekDates = getCurrentWeekDates()
                let completedCount = weekDates.filter { userProfile.isDateCompleted($0) }.count
                Text("\(completedCount)/7")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.vintagePink)
            }
            
            HStack(spacing: 0) {
                let weekDates = getCurrentWeekDates()
                ForEach(0..<7) { i in
                    let date = weekDates[i]
                    let isToday = Calendar.current.isDateInToday(date)
                    let isDone = userProfile.isDateCompleted(date)
                    
                    VStack(spacing: 8) {
                        Text(dayLabels[i])
                            .font(.system(size: 12, weight: isToday ? .bold : .medium))
                            .foregroundColor(isToday ? .vintagePink : .deepCharcoal.opacity(0.5))
                        
                        ZStack {
                            Circle()
                                .fill(isDone ? Color.vintagePink.opacity(0.15) : Color.white.opacity(0.5))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle().stroke(
                                        isToday && !isDone ? Color.vintagePink : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                            
                            if isDone {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.vintagePink)
                            } else {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.deepCharcoal.opacity(0.4))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .glassCard()
        .padding(.horizontal, 24)
    }
    
    private func getCurrentWeekDates() -> [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday-first (French)
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        // offset: Mon=0, Tue=1, ... Sun=6
        let offset = (weekday - 2 + 7) % 7
        let monday = cal.date(byAdding: .day, value: -offset, to: today)!
        return (0..<7).map { cal.date(byAdding: .day, value: $0, to: monday)! }
    }
    
    // MARK: - Stats Row (Fixed: only shows real data)
    private var statsRow: some View {
        HStack(spacing: 12) {
            statBox(icon: "trophy.fill", color: .metallicGold, value: "\(userProfile.totalSessions)", label: "Séances")
            statBox(icon: "flame.fill", color: .vintagePink, value: "\(userProfile.currentStreak)", label: "Jours")
            statBox(icon: "clock.fill", color: .deepCharcoal, value: "\(userProfile.totalMinutes)", label: "Minutes")
        }
        .padding(.horizontal, 24)
    }
    
    private func statBox(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.deepCharcoal)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "Tout", category: nil)
                ForEach(ExerciseCategory.allCases) { category in
                    filterChip(label: category.frenchLabel, category: category)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func filterChip(label: String, category: ExerciseCategory?) -> some View {
        let isSelected = selectedFilter == category
        
        return Button(action: {
            HapticManager.selection()
            withAnimation(.easeInOut) {
                selectedFilter = category
            }
        }) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .deepCharcoal)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.vintagePink : Color.white.opacity(0.8))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.vintagePink.opacity(0.3) : .clear, radius: 8, y: 4)
        }
    }
    
    // MARK: - Workout Grid
    private var workoutGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(filteredExercises.filter { userProfile.isExerciseSafe($0) }.sorted(by: { 
                let d1 = userProfile.allCompletedExerciseIDs.contains($0.id.uuidString)
                let d2 = userProfile.allCompletedExerciseIDs.contains($1.id.uuidString)
                if d1 == d2 { return false }
                return !d1 && d2
            })) { exercise in
                let isDone = userProfile.allCompletedExerciseIDs.contains(exercise.id.uuidString)
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: isDone
                                            ? [Color.nudeModern.opacity(0.15), Color.white.opacity(0.5)]
                                            : [Color.nudeModern.opacity(0.3), Color.white],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 110)
                                .overlay(
                                    ExerciseGridThumbnail(exercise: exercise)
                                        .frame(height: 110)
                                        .opacity(isDone ? 0.35 : 1.0)
                                        .grayscale(isDone ? 0.5 : 0.0)
                                )
                            
                            if isDone {
                                // Greyed out + checkmark overlay
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.6))
                                    .frame(height: 110)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.vintagePink.opacity(0.5))
                                    .padding(8)
                            } else {
                                Text(exercise.category.frenchLabel)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.vintagePink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Capsule())
                                    .padding(8)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isDone ? .deepCharcoal.opacity(0.4) : .deepCharcoal)
                                .lineLimit(1)
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 2) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 10))
                                    Text(durationLabel(exercise.duration))
                                        .font(.system(size: 10))
                                }
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(isDone ? .metallicGold.opacity(0.4) : .metallicGold)
                                    Text(exercise.difficulty.rawValue)
                                        .font(.system(size: 10))
                                }
                            }
                            .foregroundColor(.deepCharcoal.opacity(0.6))
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(8)
                    .glassCard()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Collections Feed
    private var collectionsFeed: some View {
        VStack(spacing: 14) {
            // Take the first 3 collections (or less if not available)
            ForEach(PilatesCollection.allCollections.prefix(3)) { collection in
                NavigationLink(destination:
                    CollectionDetailView(collection: collection)
                        .environmentObject(userProfile)
                ) {
                    homeCollectionCard(collection: collection)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func homeCollectionCard(collection: PilatesCollection) -> some View {
        let isDone = collection.exercises.allSatisfy { userProfile.allCompletedExerciseIDs.contains($0.id.uuidString) }
        
        return HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(collection.color.opacity(isDone ? 0.05 : 0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: collection.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(collection.color.opacity(isDone ? 0.4 : 1.0))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepCharcoal.opacity(isDone ? 0.4 : 1.0))
                    .lineLimit(1)
                
                Text(collection.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.deepCharcoal.opacity(isDone ? 0.4 : 0.7))
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(collection.color.opacity(isDone ? 0.4 : 1.0))
                        Text("\(collection.exercises.filter { userProfile.isExerciseSafe($0) }.count) exos")
                            .font(.system(size: 11, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(collection.duration)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(.deepCharcoal.opacity(isDone ? 0.3 : 0.6))
                .padding(.top, 2)
            }
            
            Spacer()
            
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.vintagePink.opacity(0.5))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepCharcoal.opacity(0.3))
            }
        }
        .padding(14)
        .glassCard()
        .opacity(isDone ? 0.6 : 1.0)
        .grayscale(isDone ? 0.8 : 0.0)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserProfile())
}
