import SwiftUI

// MARK: - Muscle Filter
enum MuscleFilter: String, CaseIterable, Identifiable {
    case all = "Tous les exercices"
    case abs = "Abdos"
    case legs = "Jambes"
    case glutes = "Fesses"
    case arms = "Bras"
    case back = "Dos"

    var id: String { rawValue }
    
    var searchTerms: [String] {
        switch self {
        case .all: return []
        case .abs: return ["transverse", "droit", "obliques", "abdominaux", "ventre"]
        case .legs: return ["quadriceps", "ischio-jambiers", "mollets", "adducteurs", "jambes"]
        case .glutes: return ["fessiers", "fessier", "fesses"]
        case .arms: return ["pectoraux", "triceps", "biceps", "deltoïdes", "épaules", "bras"]
        case .back: return ["érecteurs", "lombaires", "rhomboïdes", "carré des lombes", "trapèzes", "dos"]
        }
    }
}

// MARK: - Library Tab Type
enum LibraryTab: String, CaseIterable, Identifiable {
    case exercises = "Exercices"
    case collections = "Programmes courts"
    
    var id: String { rawValue }
}

// MARK: - Pilates Collection Model (defined here so CollectionDetailView can reference it)
struct PilatesCollection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: String
    let icon: String
    let color: Color
    let exercises: [PilatesExercise]
}

extension PilatesCollection {
    static let allCollections: [PilatesCollection] = [
        PilatesCollection(
            title: "Full Body Burn 15 min",
            subtitle: "Un entraînement complet et rapide",
            duration: "15 min",
            icon: "flame.fill",
            color: .vintagePink,
            exercises: Array(ExerciseCatalog.all30DayChallenge.filter {
                $0.category == .fullBody || $0.category == .classical
            }.prefix(8))
        ),
        PilatesCollection(
            title: "Pilates au Mur Essentiel",
            subtitle: "Utilisez le mur pour un meilleur alignement",
            duration: "20 min",
            icon: "square.dashed",
            color: .metallicGold,
            exercises: ExerciseCatalog.wallPilates
        ),
        PilatesCollection(
            title: "Ventre Plat & Abdos",
            subtitle: "Focus intense sur la sangle abdominale",
            duration: "18 min",
            icon: "figure.core.training",
            color: .deepCharcoal,
            exercises: Array(ExerciseCatalog.vod.filter { $0.category == .coreIntegration }.prefix(12))
        ),
        PilatesCollection(
            title: "Lazy Workout (Au Lit)",
            subtitle: "Pour les jours de grande fatigue",
            duration: "10 min",
            icon: "bed.double.fill",
            color: .nudeModern,
            exercises: ExerciseCatalog.bedPilates
        ),
        PilatesCollection(
            title: "Fessiers & Jambes",
            subtitle: "Sculptez et renforcez le bas du corps",
            duration: "16 min",
            icon: "figure.walk",
            color: Color(hex: "DDB263"),
            exercises: Array(ExerciseCatalog.vod.filter { $0.category == .lowerBody }.prefix(10))
        ),
        PilatesCollection(
            title: "Récupération & Souplesse",
            subtitle: "Détente et mobilité articulaire",
            duration: "12 min",
            icon: "leaf.fill",
            color: Color(hex: "A0C4A8"),
            exercises: Array(ExerciseCatalog.vod.filter { $0.category == .restorative }.prefix(8))
        ),
    ]
}

// MARK: - VOD Library View
struct VODLibraryView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var searchText: String = ""
    @State private var selectedMuscleFilter: MuscleFilter = .all
    @State private var selectedTab: LibraryTab = .collections
    @State private var favorites: Set<UUID> = []
    @State private var appear = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filteredExercises: [PilatesExercise] {
        var exercises = ExerciseCatalog.vod
            .filter { userProfile.isExerciseSafe($0) } // Injury-aware filter

        // Apply Muscle Filter
        if selectedMuscleFilter != .all {
            exercises = exercises.filter { exercise in
                let targetMusclesStr = exercise.targetMuscles.joined(separator: " ").lowercased()
                return selectedMuscleFilter.searchTerms.contains { term in
                    targetMusclesStr.contains(term.lowercased()) || exercise.name.lowercased().contains(term.lowercased()) || exercise.description.lowercased().contains(term.lowercased())
                }
            }
        }

        // Apply Search Text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            exercises = exercises.filter {
                $0.name.lowercased().contains(query) ||
                $0.englishName.lowercased().contains(query) ||
                $0.targetMuscles.contains(where: { $0.lowercased().contains(query) }) ||
                $0.category.frenchLabel.lowercased().contains(query)
            }
        }

        // Sort by completion status first (incomplete at top), then difficulty
        return exercises.sorted { ex1, ex2 in
            let done1 = userProfile.allCompletedExerciseIDs.contains(ex1.id.uuidString)
            let done2 = userProfile.allCompletedExerciseIDs.contains(ex2.id.uuidString)
            if done1 == done2 {
                return ex1.difficulty.rawValue < ex2.difficulty.rawValue
            }
            return !done1 && done2
        }
    }

    private func durationLabel(_ seconds: Int) -> String {
        if seconds >= 60 { return "\(seconds / 60) min" }
        return "\(seconds)s"
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [Color.champagneBlush.opacity(0.3), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom Header Top
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bibliothèque")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.deepCharcoal)
                            .padding(.horizontal, 24)
                        
                        // Tab Selector
                        HStack(spacing: 0) {
                            ForEach(LibraryTab.allCases) { tab in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedTab = tab
                                    }
                                    HapticManager.selection()
                                }) {
                                    VStack(spacing: 8) {
                                        Text(tab.rawValue)
                                            .font(.system(size: 15, weight: selectedTab == tab ? .bold : .medium))
                                            .foregroundColor(selectedTab == tab ? .vintagePink : .deepCharcoal.opacity(0.5))
                                        
                                        Rectangle()
                                            .fill(selectedTab == tab ? Color.vintagePink : Color.clear)
                                            .frame(height: 3)
                                            .cornerRadius(1.5)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 10)
                    .background(Color.clear)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            if selectedTab == .exercises {
                                searchBar
                                muscleFilterPills
                                exerciseGrid
                            } else {
                                collectionsView
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appear = true }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.deepCharcoal.opacity(0.4))

            TextField("Rechercher un exercice, muscle...", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(.deepCharcoal)

            if !searchText.isEmpty {
                Button(action: {
                    withAnimation { searchText = "" }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.deepCharcoal.opacity(0.3))
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : -20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appear)
    }

    // MARK: - Muscle Filter Pills
    private var muscleFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MuscleFilter.allCases) { filter in
                    let isSelected = selectedMuscleFilter == filter
                    
                    Button(action: {
                        HapticManager.selection()
                        withAnimation(.easeInOut) {
                            selectedMuscleFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
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
                            .shadow(color: isSelected ? Color.vintagePink.opacity(0.3) : Color.clear, radius: 8, y: 4)
                            .scaleEffect(isSelected ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMuscleFilter)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Exercise Grid
    private var exerciseGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(filteredExercises.count) Exercices trouvés")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.6))
                .padding(.horizontal, 24)
                
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(filteredExercises.enumerated()), id: \.element.id) { index, exercise in
                    exerciseCard(exercise)
                        .opacity(appear ? 1 : 0)
                        .offset(x: appear ? 0 : 40)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appear)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func exerciseCard(_ exercise: PilatesExercise) -> some View {
        let isDone = userProfile.allCompletedExerciseIDs.contains(exercise.id.uuidString)
        return NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: isDone
                                    ? [Color.nudeModern.opacity(0.1), Color.white.opacity(0.4)]
                                    : [Color.nudeModern.opacity(0.3), Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 110)

                    ExerciseGridThumbnail(exercise: exercise)
                        .frame(height: 110)
                        .opacity(isDone ? 0.35 : 1.0)
                        .grayscale(isDone ? 0.5 : 0.0)
                    
                    if isDone {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.6))
                            .frame(height: 110)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.vintagePink.opacity(0.5))
                            .padding(8)
                    } else {
                        // Fav button
                        Button(action: {
                            HapticManager.selection()
                            toggleFavorite(exercise.id)
                        }) {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: favorites.contains(exercise.id) ? "heart.fill" : "heart")
                                        .font(.system(size: 14))
                                        .foregroundColor(favorites.contains(exercise.id) ? .vintagePink : .deepCharcoal.opacity(0.5))
                                )
                        }
                        .padding(8)
                    }
                }
                .clipped()
                .cornerRadius(20)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isDone ? .deepCharcoal.opacity(0.4) : .deepCharcoal)
                        .lineLimit(1)

                    Text(exercise.category.frenchLabel)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.vintagePink)

                    HStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(durationLabel(exercise.duration))
                                .font(.system(size: 11, weight: .medium))
                        }
                        
                        if exercise.isWallPilates {
                            HStack(spacing: 4) {
                                Image(systemName: "square.fill")
                                    .font(.system(size: 11))
                                Text("Mur")
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                        if exercise.isBedPilates {
                            HStack(spacing: 4) {
                                Image(systemName: "bed.double.fill")
                                    .font(.system(size: 11))
                                Text("Lit")
                                    .font(.system(size: 11, weight: .medium))
                            }
                        }
                    }
                    .foregroundColor(.deepCharcoal.opacity(0.6))
                    .padding(.top, 2)
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
            .padding(8)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Collections View (Programs)
    private var sortedCollections: [PilatesCollection] {
        PilatesCollection.allCollections.sorted { c1, c2 in
            let done1 = c1.exercises.allSatisfy { userProfile.allCompletedExerciseIDs.contains($0.id.uuidString) }
            let done2 = c2.exercises.allSatisfy { userProfile.allCompletedExerciseIDs.contains($0.id.uuidString) }
            if done1 == done2 { return false } // keep definition order
            return !done1 && done2
        }
    }

    private var collectionsView: some View {
        VStack(spacing: 20) {
            ForEach(sortedCollections) { collection in
                NavigationLink(destination:
                    CollectionDetailView(collection: collection)
                        .environmentObject(userProfile)
                ) {
                    collectionCard(collection: collection)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func collectionCard(collection: PilatesCollection) -> some View {
        let isDone = collection.exercises.allSatisfy { userProfile.allCompletedExerciseIDs.contains($0.id.uuidString) }
        
        return HStack(spacing: 16) {
            // Icon Box with mini animated figure
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(collection.color.opacity(isDone ? 0.05 : 0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: collection.exercises.first.map { exerciseCategoryIcon($0.category) } ?? "figure.pilates")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(collection.color.opacity(isDone ? 0.4 : 1.0))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(collection.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.deepCharcoal.opacity(isDone ? 0.4 : 1.0))
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                
                Text(collection.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.deepCharcoal.opacity(isDone ? 0.4 : 0.7))
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(collection.color.opacity(isDone ? 0.4 : 1.0))
                        Text("\(collection.exercises.filter { userProfile.isExerciseSafe($0) }.count) exercices")
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(collection.duration)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(.deepCharcoal.opacity(isDone ? 0.3 : 0.6))
                .padding(.top, 4)
            }
            
            Spacer()
            
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.vintagePink.opacity(0.5))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.deepCharcoal.opacity(0.3))
            }
        }
        .padding(16)
        .glassCard()
        .opacity(isDone ? 0.6 : 1.0)
        .grayscale(isDone ? 0.8 : 0.0)
    }

    // MARK: - Helpers
    private func toggleFavorite(_ id: UUID) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
    }
}

#Preview {
    VODLibraryView()
        .environmentObject(UserProfile())
}

