import Foundation

// MARK: - Exercise Category

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case coreIntegration = "Core"
    case lowerBody = "Fessiers"
    case upperBody = "Corps Supérieur"
    case fullBody = "Complet"
    case classical = "Classique"
    case restorative = "Restorateur"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coreIntegration: return "figure.core.training"
        case .lowerBody: return "figure.walk"
        case .upperBody: return "figure.arms.open"
        case .fullBody: return "figure.pilates"
        case .classical: return "figure.mind.and.body"
        case .restorative: return "leaf.fill"
        }
    }

    var frenchLabel: String { rawValue }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, CaseIterable, Identifiable {
    case beginner = "Débutante"
    case intermediate = "Intermédiaire"
    case advanced = "Avancée"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .beginner: return "E6C7B2"
        case .intermediate: return "E8B6C3"
        case .advanced: return "DDB263"
        }
    }
}

// MARK: - Pilates Exercise

struct PilatesExercise: Identifiable, Hashable {
    let id: UUID
    let name: String
    let englishName: String
    let category: ExerciseCategory
    let difficulty: DifficultyLevel
    let description: String
    let targetMuscles: [String]
    let precautions: String?
    let duration: Int // seconds
    let isWallPilates: Bool
    let isBedPilates: Bool
    let sfSymbol: String
    let lottieFileName: String?
    let youtubeVideoID: String?

    init(
        id: UUID = UUID(),
        name: String,
        englishName: String,
        category: ExerciseCategory,
        difficulty: DifficultyLevel = .beginner,
        description: String,
        targetMuscles: [String],
        precautions: String? = nil,
        duration: Int = 45,
        isWallPilates: Bool = false,
        isBedPilates: Bool = false,
        sfSymbol: String = "figure.pilates",
        lottieFileName: String? = nil,
        youtubeVideoID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.englishName = englishName
        self.category = category
        self.difficulty = difficulty
        self.description = description
        self.targetMuscles = targetMuscles
        self.precautions = precautions
        self.duration = duration
        self.isWallPilates = isWallPilates
        self.isBedPilates = isBedPilates
        self.sfSymbol = sfSymbol
        self.lottieFileName = lottieFileName
        self.youtubeVideoID = youtubeVideoID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PilatesExercise, rhs: PilatesExercise) -> Bool {
        lhs.id == rhs.id
    }

    var gifFileName: String {
        let formattedName = englishName.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        return "exercise_\(formattedName)"
    }
}

// MARK: - Exercise Catalog

struct ExerciseCatalog {

    // MARK: 30-Day Challenge Exercises (30 exercises, progressive)

    static let all30DayChallenge: [PilatesExercise] = [
        // Week 1: Beginner Foundation
        PilatesExercise(
            name: "Respiration Pilates",
            englishName: "Pilates Breathing",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Allongez-vous sur le dos, genoux pliés. Inspirez par le nez en gonflant les côtes latéralement, expirez par la bouche en activant le transverse. Cet exercice fondamental établit la connexion corps-esprit.",
            targetMuscles: ["Transverse", "Diaphragme", "Plancher pelvien"],
            duration: 45,
            sfSymbol: "lungs.fill"
        ),
        PilatesExercise(
            name: "Bascule du Bassin",
            englishName: "Pelvic Tilt",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Allongée sur le dos, genoux pliés, pieds à plat. Basculez doucement le bassin vers l'avant puis vers l'arrière en engageant les abdominaux profonds. Maintenez chaque position 3 secondes.",
            targetMuscles: ["Transverse", "Lombaires", "Fessiers"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Pont Fessier",
            englishName: "Glute Bridge",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Allongée sur le dos, pieds à plat au sol. Soulevez les hanches en contractant les fessiers, créant une ligne droite des épaules aux genoux. Redescendez vertèbre par vertèbre.",
            targetMuscles: ["Grand fessier", "Ischio-jambiers", "Transverse"],
            precautions: "Évitez de cambrer le bas du dos en position haute.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Élévation de Jambe Allongée",
            englishName: "Supine Leg Lift",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Sur le dos, une jambe pliée pied au sol, l'autre tendue vers le plafond. Abaissez lentement la jambe tendue sans toucher le sol, puis remontez. Gardez le bas du dos collé au tapis.",
            targetMuscles: ["Psoas", "Transverse", "Quadriceps"],
            precautions: "Ne descendez pas la jambe plus bas que votre contrôle abdominal le permet.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Le Chat-Vache",
            englishName: "Cat-Cow Stretch",
            category: .restorative,
            difficulty: .beginner,
            description: "À quatre pattes, alternez entre arrondir le dos (chat) en expirant et creuser le dos (vache) en inspirant. Mobilisez chaque vertèbre une à une pour assouplir toute la colonne.",
            targetMuscles: ["Érecteurs du rachis", "Abdominaux", "Trapèzes"],
            duration: 45,
            sfSymbol: "figure.mind.and.body"
        ),
        PilatesExercise(
            name: "Insecte Mort",
            englishName: "Dead Bug",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Sur le dos, bras tendus vers le plafond, genoux à 90°. Étendez simultanément le bras droit et la jambe gauche vers le sol, puis revenez. Alternez les côtés en gardant le dos plaqué.",
            targetMuscles: ["Transverse", "Obliques", "Psoas"],
            precautions: "Gardez le bas du dos en contact permanent avec le sol.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Étirement Colonne Assise",
            englishName: "Seated Spine Stretch",
            category: .restorative,
            difficulty: .beginner,
            description: "Assise, jambes tendues devant vous, bras levés. Enroulez le tronc vers l'avant vertèbre par vertèbre en expirant, comme si vous passiez par-dessus un ballon. Remontez en déroulant.",
            targetMuscles: ["Érecteurs du rachis", "Ischio-jambiers", "Transverse"],
            duration: 45,
            sfSymbol: "figure.mind.and.body"
        ),

        // Week 2: Building Core Strength
        PilatesExercise(
            name: "Le Cent",
            englishName: "The Hundred",
            category: .classical,
            difficulty: .intermediate,
            description: "Allongée, tête relevée, jambes à 45°. Battez les bras vigoureusement de haut en bas en inspirant sur 5 temps et expirant sur 5 temps. L'exercice signature du Pilates classique.",
            targetMuscles: ["Grand droit", "Transverse", "Obliques"],
            precautions: "En cas de douleur cervicale, gardez la tête posée au sol.",
            duration: 50,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Enroulement Vertébral",
            englishName: "Roll Up",
            category: .classical,
            difficulty: .intermediate,
            description: "Allongée, bras au-dessus de la tête. Enroulez le tronc vers l'avant vertèbre par vertèbre jusqu'à toucher les orteils, puis déroulez lentement. Contrôlez chaque phase du mouvement.",
            targetMuscles: ["Grand droit", "Transverse", "Psoas"],
            precautions: "Pliez légèrement les genoux si les ischio-jambiers sont raides.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Cercle d'Une Jambe",
            englishName: "One Leg Circle",
            category: .classical,
            difficulty: .intermediate,
            description: "Sur le dos, une jambe tendue vers le plafond. Dessinez des cercles avec la jambe en gardant le bassin stable. 5 cercles dans chaque sens, puis changez de jambe.",
            targetMuscles: ["Psoas", "Adducteurs", "Transverse", "Quadriceps"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Rouler Comme une Balle",
            englishName: "Rolling Like a Ball",
            category: .classical,
            difficulty: .intermediate,
            description: "Assise en boule, genoux pliés contre la poitrine, pieds décollés. Roulez en arrière jusqu'aux omoplates puis revenez en équilibre. Le massage vertébral ultime.",
            targetMuscles: ["Grand droit", "Transverse", "Érecteurs du rachis"],
            precautions: "Ne roulez jamais sur la nuque. Arrêtez aux omoplates.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Étirement Jambe Tendue Simple",
            englishName: "Single Leg Stretch",
            category: .classical,
            difficulty: .intermediate,
            description: "Allongée, tête relevée. Ramenez un genou vers la poitrine pendant que l'autre jambe s'étend à 45°. Alternez en rythme, coordonnant bras et jambes.",
            targetMuscles: ["Grand droit", "Obliques", "Psoas", "Quadriceps"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Étirement Jambes Tendues Double",
            englishName: "Double Leg Stretch",
            category: .classical,
            difficulty: .intermediate,
            description: "Allongée en position de table. Étendez simultanément bras et jambes, puis ramenez tout vers le centre. Un exercice de coordination et de force abdominale.",
            targetMuscles: ["Grand droit", "Transverse", "Psoas"],
            precautions: "Gardez le bas du dos au sol pendant l'extension.",
            duration: 50,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "La Scie",
            englishName: "The Saw",
            category: .fullBody,
            difficulty: .intermediate,
            description: "Assise, jambes écartées, bras en croix. Tournez le buste et penchez-vous pour toucher le pied opposé avec la main, en expirant profondément. Alternez les côtés.",
            targetMuscles: ["Obliques", "Ischio-jambiers", "Érecteurs du rachis"],
            duration: 45,
            sfSymbol: "figure.mind.and.body"
        ),

        // Week 3: Intermediate Challenge
        PilatesExercise(
            name: "Le Cygne",
            englishName: "Swan Dive Prep",
            category: .fullBody,
            difficulty: .intermediate,
            description: "Sur le ventre, mains sous les épaules. Soulevez le buste en extension en gardant le pubis au sol. Ouvrez la poitrine et allongez la nuque. Redescendez avec contrôle.",
            targetMuscles: ["Érecteurs du rachis", "Grand fessier", "Rhomboïdes"],
            precautions: "Évitez si vous avez des problèmes de lombaires. Ne forcez pas l'extension.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Coups de Pied Latéraux",
            englishName: "Side Kick Series",
            category: .lowerBody,
            difficulty: .intermediate,
            description: "Allongée sur le côté, jambes légèrement devant. Balancez la jambe supérieure d'avant en arrière avec contrôle, en gardant le tronc stable. Travaillez les fessiers et les abducteurs.",
            targetMuscles: ["Moyen fessier", "Abducteurs", "Obliques"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "La Planche",
            englishName: "Plank",
            category: .fullBody,
            difficulty: .intermediate,
            description: "En appui sur les avant-bras et les orteils, corps en ligne droite. Engagez le transverse, serrez les fessiers, et maintenez la position. La fondation de la stabilité du tronc.",
            targetMuscles: ["Transverse", "Grand droit", "Deltoïdes", "Fessiers"],
            precautions: "Ne laissez pas les hanches s'affaisser ou monter trop haut.",
            duration: 45,
            sfSymbol: "figure.core.training"
        ),
        PilatesExercise(
            name: "La Sirène",
            englishName: "Mermaid Stretch",
            category: .restorative,
            difficulty: .intermediate,
            description: "Assise en Z, un bras tendu vers le plafond. Inclinez-vous latéralement en créant un arc avec tout le côté du corps. Respirez dans les côtes flottantes et allongez-vous.",
            targetMuscles: ["Obliques", "Carré des lombes", "Intercostaux"],
            duration: 45,
            sfSymbol: "figure.mind.and.body"
        ),
        PilatesExercise(
            name: "Torsion Vertébrale",
            englishName: "Spine Twist",
            category: .restorative,
            difficulty: .intermediate,
            description: "Assise, jambes tendues, bras en croix. Tournez le buste d'un côté en expirant, en gardant le bassin ancré. Revenez au centre et tournez de l'autre côté.",
            targetMuscles: ["Obliques", "Érecteurs du rachis", "Transverse"],
            duration: 45,
            sfSymbol: "figure.mind.and.body"
        ),
        PilatesExercise(
            name: "Le Nageur",
            englishName: "Swimming",
            category: .fullBody,
            difficulty: .intermediate,
            description: "Sur le ventre, bras et jambes tendus. Soulevez bras et jambes alternés en battant rapidement, comme si vous nagiez. Gardez le regard vers le sol.",
            targetMuscles: ["Érecteurs du rachis", "Fessiers", "Deltoïdes", "Ischio-jambiers"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),

        // Week 4: Advanced Finishing Strong
        PilatesExercise(
            name: "Le Teaser",
            englishName: "Teaser",
            category: .classical,
            difficulty: .advanced,
            description: "Allongée, montez simultanément le buste et les jambes pour former un V. Bras tendus parallèles aux jambes. L'exercice ultime d'équilibre et de contrôle Pilates.",
            targetMuscles: ["Grand droit", "Transverse", "Psoas", "Quadriceps"],
            precautions: "Progressez vers la version complète. Commencez avec les pieds au sol.",
            duration: 50,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Planche Latérale",
            englishName: "Side Plank",
            category: .fullBody,
            difficulty: .advanced,
            description: "En appui sur un avant-bras, corps en ligne, pieds empilés. Soulevez les hanches et maintenez. Optionnel: levez le bras libre vers le plafond pour plus de défi.",
            targetMuscles: ["Obliques", "Moyen fessier", "Deltoïdes", "Transverse"],
            precautions: "Modifiez en posant le genou inférieur au sol si nécessaire.",
            duration: 45,
            sfSymbol: "figure.core.training"
        ),
        PilatesExercise(
            name: "Touches d'Orteil Simples",
            englishName: "Single Toe Taps",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Sur le dos, genoux pliés à 90° en position de chaise renversée. Descendez lentement un pied vers le sol jusqu'à ce que l'orteil touche, puis ramenez-le, en gardant le bassin stable.",
            targetMuscles: ["Transverse", "Psoas", "Grand droit"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Pompes Pilates",
            englishName: "Pilates Push-Up",
            category: .upperBody,
            difficulty: .advanced,
            description: "Debout, enroulez le tronc vers le sol, marchez les mains en planche, effectuez 3 pompes, puis marchez les mains vers les pieds et déroulez. Combinaison fluide de force et flexibilité.",
            targetMuscles: ["Pectoraux", "Triceps", "Deltoïdes", "Transverse"],
            duration: 50,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Ciseaux",
            englishName: "Scissors",
            category: .classical,
            difficulty: .advanced,
            description: "Sur le dos, soulevez les hanches soutenues par les mains. Écartez les jambes en ciseaux, alternant rapidement. Un exercice de contrôle et de coordination avancé.",
            targetMuscles: ["Psoas", "Ischio-jambiers", "Grand droit", "Transverse"],
            precautions: "Évitez si vous avez des problèmes cervicaux.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "La Bicyclette",
            englishName: "Bicycle",
            category: .classical,
            difficulty: .advanced,
            description: "Position chandelle soutenue. Pédalez les jambes en alternance, étendant une jambe vers le sol pendant que l'autre monte. Mouvement fluide et contrôlé.",
            targetMuscles: ["Psoas", "Quadriceps", "Ischio-jambiers", "Transverse"],
            precautions: "Ne pratiquez pas en cas de douleurs cervicales ou de hernie discale.",
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Torsion de la Hanche",
            englishName: "Hip Twist",
            category: .coreIntegration,
            difficulty: .advanced,
            description: "Assise en appui sur les mains derrière, jambes tendues à 45°. Dessinez un cercle avec les deux jambes ensemble en gardant le tronc parfaitement stable.",
            targetMuscles: ["Obliques", "Transverse", "Psoas", "Adducteurs"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Touches d'Orteils Doubles",
            englishName: "Double Toe Taps",
            category: .coreIntegration,
            difficulty: .intermediate,
            description: "Sur le dos, genoux à 90°. Descendez les deux pieds ensemble vers le sol en expirant, sans creuser le bas du dos, puis remontez en inspirant. Fort engagement du transverse.",
            targetMuscles: ["Transverse", "Grand droit", "Psoas"],
            duration: 45,
            sfSymbol: "figure.pilates"
        ),
    ]

    // MARK: Wall Pilates (10 exercises)

    static let wallPilates: [PilatesExercise] = [
        PilatesExercise(
            name: "Déroulé Mural",
            englishName: "Wall Roll Down",
            category: .restorative,
            difficulty: .beginner,
            description: "Dos contre le mur, pieds à 30 cm du mur. Déroulez le tronc vertèbre par vertèbre en décollant du mur, puis remontez lentement. Excellent pour la mobilité vertébrale.",
            targetMuscles: ["Érecteurs du rachis", "Transverse", "Ischio-jambiers"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.mind.and.body"
        ),
        PilatesExercise(
            name: "Squats au Poids du Corps",
            englishName: "Bodyweight Squats",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Debout, pieds écartés largeur des épaules. Fléchissez les genoux et descendez les hanches comme pour vous asseoir sur une chaise. Gardez le dos droit et repoussez sur vos talons pour remonter.",
            targetMuscles: ["Quadriceps", "Fessiers", "Ischio-jambiers"],
            duration: 45,
            isWallPilates: false,
            sfSymbol: "figure.strengthtraining.traditional"
        ),
        PilatesExercise(
            name: "Pont Fessier Mural",
            englishName: "Wall Glute Bridge",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Allongée, pieds à plat contre le mur, genoux à 90°. Soulevez les hanches en contractant les fessiers. Le mur offre un ancrage stable pour un meilleur engagement musculaire.",
            targetMuscles: ["Grand fessier", "Ischio-jambiers", "Transverse"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Pompes Murales",
            englishName: "Wall Push-Ups",
            category: .upperBody,
            difficulty: .beginner,
            description: "Face au mur, mains à hauteur d'épaules. Fléchissez les bras pour rapprocher la poitrine du mur, puis repoussez. Version accessible des pompes classiques, parfaite pour débuter.",
            targetMuscles: ["Pectoraux", "Triceps", "Deltoïdes"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Planche sur les Genoux",
            englishName: "Kneeling Plank",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "En appui sur les mains et les genoux, avancez les mains pour créer une ligne droite des genoux aux épaules. Engagez les abdominaux et maintenez la position sans cambrer le dos.",
            targetMuscles: ["Transverse", "Deltoïdes", "Grand droit"],
            duration: 45,
            sfSymbol: "figure.core.training"
        ),
        PilatesExercise(
            name: "Abduction Murale",
            englishName: "Wall Leg Abduction",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Dos au mur pour l'équilibre. Levez la jambe latéralement en gardant le corps droit. Le mur sert de support pour isoler les muscles de la hanche. Alternez les côtés.",
            targetMuscles: ["Moyen fessier", "Abducteurs", "Obliques"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Squats Muraux Pulsés",
            englishName: "Wall Pulse Squats",
            category: .lowerBody,
            difficulty: .intermediate,
            description: "En position de chaise murale, effectuez de petits mouvements de pulsation en montant et descendant de quelques centimètres. Le brûlé musculaire intense renforce les cuisses en profondeur.",
            targetMuscles: ["Quadriceps", "Fessiers", "Mollets"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Extension Mollets au Mur",
            englishName: "Wall Calf Raises",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Face au mur, mains en appui léger. Montez sur la pointe des pieds en contractant les mollets, puis redescendez lentement. Le mur assure l'équilibre pour un mouvement propre.",
            targetMuscles: ["Mollets", "Soléaire", "Stabilisateurs de la cheville"],
            duration: 45,
            isWallPilates: true,
            sfSymbol: "figure.pilates"
        ),
        PilatesExercise(
            name: "Étirement Ischio-Jambiers au Mur",
            englishName: "Wall Hamstring Stretch",
            category: .restorative,
            difficulty: .beginner,
            description: "Allongée, fesses contre le mur, jambes tendues vers le plafond le long du mur. Laissez la gravité étirer doucement les ischio-jambiers. Restez et respirez profondément.",
            targetMuscles: ["Ischio-jambiers", "Mollets", "Lombaires"],
            duration: 60,
            isWallPilates: true,
            sfSymbol: "figure.mind.and.body"
        ),
        PilatesExercise(
            name: "Jambes au Mur Relaxation",
            englishName: "Legs Up the Wall",
            category: .restorative,
            difficulty: .beginner,
            description: "Allongée, fesses proches du mur, jambes tendues contre le mur. Position restauratrice qui favorise le retour veineux et la relaxation profonde. Idéale en fin de séance.",
            targetMuscles: ["Ischio-jambiers", "Lombaires", "Système circulatoire"],
            duration: 60,
            isWallPilates: true,
            sfSymbol: "leaf.fill"
        ),
    ]

    // MARK: Bed / Lazy Pilates (5 exercises)

    static let bedPilates: [PilatesExercise] = [
        PilatesExercise(
            name: "Bascule du Bassin au Lit",
            englishName: "Bed Pelvic Tilt",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Allongée sur votre lit, genoux pliés. Basculez doucement le bassin en appuyant le bas du dos dans le matelas. La surface souple du lit rend le mouvement encore plus doux pour le dos.",
            targetMuscles: ["Transverse", "Lombaires", "Plancher pelvien"],
            duration: 60,
            isBedPilates: true,
            sfSymbol: "bed.double.fill"
        ),
        PilatesExercise(
            name: "Torsion Allongée Douce",
            englishName: "Supine Spinal Twist",
            category: .restorative,
            difficulty: .beginner,
            description: "Sur le dos, genoux pliés. Laissez tomber les genoux d'un côté en tournant la tête de l'autre. La douceur du matelas soutient le dos pendant cette rotation bienfaisante.",
            targetMuscles: ["Obliques", "Érecteurs du rachis", "Piriforme"],
            duration: 60,
            isBedPilates: true,
            sfSymbol: "bed.double.fill"
        ),
        PilatesExercise(
            name: "Pont Doux au Lit",
            englishName: "Gentle Bed Bridge",
            category: .lowerBody,
            difficulty: .beginner,
            description: "Allongée sur le lit, pieds à plat. Soulevez lentement les hanches, maintenez 5 secondes, redescendez. La surface moelleuse amortit et rend l'exercice accessible à toutes.",
            targetMuscles: ["Grand fessier", "Ischio-jambiers", "Transverse"],
            duration: 60,
            isBedPilates: true,
            sfSymbol: "bed.double.fill"
        ),
        PilatesExercise(
            name: "Élévation de Jambe au Lit",
            englishName: "Bed Leg Raise",
            category: .coreIntegration,
            difficulty: .beginner,
            description: "Allongée, levez une jambe vers le plafond en expirant, redescendez en inspirant. Le matelas soutient votre dos pour un mouvement confortable et efficace.",
            targetMuscles: ["Psoas", "Transverse", "Quadriceps"],
            duration: 60,
            isBedPilates: true,
            sfSymbol: "bed.double.fill"
        ),
        PilatesExercise(
            name: "Étirement des Poignets",
            englishName: "Wrist Stretch",
            category: .restorative,
            difficulty: .beginner,
            description: "Assise confortablement ou à genoux. Tendez un bras devant vous, paume vers l'avant, doigts vers le haut (puis vers le bas) et tirez doucement avec l'autre main. Soulage les tensions des poignets.",
            targetMuscles: ["Fléchisseurs de l'avant-bras", "Extenseurs de l'avant-bras"],
            duration: 60,
            isBedPilates: true,
            sfSymbol: "hand.raised.fill"
        ),
    ]

    // MARK: VOD Library (20+ exercises)

    static let vod: [PilatesExercise] = {
        // Combine all unique exercises from the catalogs plus additional ones
        var exercises: [PilatesExercise] = []

        // Include the 30-day challenge exercises
        exercises.append(contentsOf: all30DayChallenge)

        // Include wall pilates
        exercises.append(contentsOf: wallPilates)

        // Include bed pilates
        exercises.append(contentsOf: bedPilates)

        // Additional VOD-only exercises
        exercises.append(contentsOf: [
            PilatesExercise(
                name: "Le Tire-Bouchon",
                englishName: "Corkscrew",
                category: .classical,
                difficulty: .advanced,
                description: "Sur le dos, jambes tendues vers le plafond. Dessinez des cercles avec les deux jambes ensemble, en passant d'un côté à l'autre. Gardez les épaules au sol et le tronc stable.",
                targetMuscles: ["Obliques", "Transverse", "Psoas", "Adducteurs"],
                precautions: "Commencez avec de petits cercles et agrandissez progressivement.",
                duration: 45,
                sfSymbol: "figure.pilates"
            ),
            PilatesExercise(
                name: "Le Canif",
                englishName: "Jackknife",
                category: .classical,
                difficulty: .advanced,
                description: "Sur le dos, jambes tendues. Roulez les jambes par-dessus la tête puis étendez-les vers le plafond en soulevant les hanches. Redescendez vertèbre par vertèbre. Puissance et contrôle.",
                targetMuscles: ["Grand droit", "Transverse", "Érecteurs du rachis"],
                precautions: "Exercice avancé. Maîtrisez le Roll Over avant de tenter celui-ci.",
                duration: 50,
                sfSymbol: "figure.pilates"
            ),
            PilatesExercise(
                name: "Étirement du Pigeon",
                englishName: "Pigeon Stretch",
                category: .restorative,
                difficulty: .beginner,
                description: "Genou droit devant, jambe gauche allongée derrière. Penchez le buste vers l'avant pour un étirement profond du piriforme et des fessiers. Respirez et relâchez les tensions.",
                targetMuscles: ["Piriforme", "Grand fessier", "Psoas"],
                duration: 60,
                sfSymbol: "figure.mind.and.body"
            ),
            PilatesExercise(
                name: "Planche avec Élévation de Jambe",
                englishName: "Plank Leg Lift",
                category: .fullBody,
                difficulty: .advanced,
                description: "En position de planche, levez alternativement une jambe en la gardant tendue. Maintenez les hanches stables et le centre engagé. Développe l'équilibre et la force globale.",
                targetMuscles: ["Transverse", "Fessiers", "Deltoïdes", "Érecteurs du rachis"],
                duration: 45,
                sfSymbol: "figure.core.training"
            ),
            PilatesExercise(
                name: "Rotation Thoracique",
                englishName: "Thoracic Rotation",
                category: .restorative,
                difficulty: .beginner,
                description: "À quatre pattes, placez une main derrière la tête. Tournez le tronc vers le haut en ouvrant le coude vers le plafond, puis refermez. Améliore la mobilité du haut du dos.",
                targetMuscles: ["Obliques", "Rhomboïdes", "Trapèzes"],
                duration: 45,
                sfSymbol: "figure.mind.and.body"
            ),
        ])

        return exercises
    }()
}
