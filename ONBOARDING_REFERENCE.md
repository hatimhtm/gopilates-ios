# GoPilates Onboarding — Complete Screen-by-Screen Reference
# CRITICAL: ios-ux-craftsman MUST read this file before writing any onboarding code.
# Source: User-provided PDF reference (Untitled_(1).pdf) — this is the gold standard.

## OUTPUT DIRECTORY
ALL files go in: `/Users/lorddecay/Desktop/ViralFactory/Go pilates /GoPilatesApp/`

## DESIGN NOTES FROM PDF
- Background: Very light champagne/near-white (#FDE2DB or even lighter)
- "Suivant" / "C'est parti" buttons: DARK (charcoal #3A2A2F), NOT gold — gold is for accents only
- Selection cards: Light frosted glass, checkmark on right when selected
- Weight/height pickers: Large bold number (system size 72-80pt), unit label beside it
- Body silhouettes: Simple flat illustrations (can use Rectangle/capsule shapes or SF Symbols)
- The affirmation screens (screens 35-37): FULL BLEED photo backgrounds with Oui/Incertain buttons at bottom
- Social proof screens: Large stat numbers in accent color, testimonial-style layout
- Progress bar: Shown at top on EVERY onboarding screen

## COMPLETE ONBOARDING FLOW (40 screens in order)

### Phase 1 — Empathic Alignment (Screens 1-4)

**Screen 1: Greeting**
- Coach circular avatar image at top center (use a placeholder circle with person SF Symbol)
- Title: "Bonjour, je suis votre coach personnel"
- Subtitle: "Nous allons vous poser quelques questions pour personnaliser un plan de Pilates unique pour vous."
- CTA button: "C'est parti !" (dark charcoal, full width, rounded)
- NO progress bar on this screen

**Screen 2: Motivation**
- Title: "Qu'est-ce qui vous motive le plus ?"
- Progress bar at top (step 1/~20)
- Options (single-select, checkmark cards):
  * "Remise en forme" (with heart icon)
  * "Avoir un meilleur physique" (with figure icon)
  * "Réduire le stress et détente" (with peace icon)
  * "Dormez mieux" (with moon icon)
  * "Trouver l'idéal de soi" (with star icon)
- Button: "Suivant" (dark, disabled until selection)

**Screen 3: Pilates Familiarity**
- Title: "Êtes-vous familière avec le Pilates ?"
- Progress bar
- Options (single-select):
  * "J'ai à peine entendu parler"
  * "J'ai fait plusieurs fois"
  * "Je suis expérimentée"
- Button: "Suivant"

**Screen 4: Main Goal**
- Title: "Quel est votre objectif principal ?"
- Progress bar
- Options (single-select):
  * "Perdre du poids"
  * "Remise en forme"
  * "Renforcez vos muscles"
  * "Améliorer votre santé"
  * "Améliorer la flexibilité"
  * "Affiner la posture"
- Button: "Suivant"

### Phase 2 — Body Targeting (Screens 5-6)

**Screen 5: Body Zone Selection**
- Title: "Choisissez votre domaine de concentration"
- Progress bar
- Center: Female body silhouette illustration (use a stylized ZStack of shapes to create a simple female outline — torso, arms, legs sections as tappable areas)
- Zone labels on sides pointing to body areas:
  * "Corps en entier" (whole body)
  * "Bras" (arms)
  * "Abdos" (core)
  * "Fesse et jambes" (glutes & legs)
- Multi-select allowed
- When zone tapped: highlight it with accent color (#DDB263 or #E8B6C3)
- Button: "Suivant"

**Screen 6: Zone Confirmed (same view, zone is highlighted)**
- Just the same screen with a zone visually selected
- Automatically transitions after tap

### Phase 3 — Biometrics (Screens 7-10)

**Screen 7: Height**
- Title: "Quelle taille faites-vous ?"
- Progress bar
- Toggle: cm | ft (top right)
- LARGE picker: scrollable drum/wheel style
  * Center value: HUGE bold text (size 72pt) e.g. "165"
  * Unit: "cm" in smaller text beside it
  * Above/below: lighter, smaller adjacent values
- Use a UIPicker-style SwiftUI Picker with .wheel style, wrapped elegantly
- Button: "Suivant"

**Screen 8: Current Weight**
- Title: "Quel est votre poids actuel ?"
- Progress bar
- Toggle: kg | lbs
- Same large wheel picker: "55.0" with "kg"
- Decimal support (0.5 increments or 0.1)
- Button: "Suivant"

**Screen 9: Target Weight**
- Title: "Quel est votre poids cible ?"
- Progress bar
- Same large wheel picker: "59.0" with "kg"
- Note: Show current weight small above for reference
- Button: "Suivant"

**Screen 10: Future Pacing — "Perdre Xkg est possible!"**
- NO button initially, shows animation then auto-advance after 2s OR tap anywhere
- BIG motivational headline: "Perdre 5.9kg est possible. Réalise-le !"
  * "5.9kg" is calculated dynamically from (currentWeight - targetWeight)
- Below: Downward curving graph line (use a custom Path/Shape)
  * X-axis: current date → target date
  * Y-axis: currentWeight → targetWeight
  * Small dot markers at start and end
  * Gradient fill under the curve (light pink to transparent)
- Below graph: "Votre objectif · avr. 23" (calculated target date, ~3 months out)
- Small text: "Des exercices changeront votre vie en seulement X semaines grâce à un programme personnalisé."
- Button: "Suivant"

### Phase 4 — Physical Profile (Screens 11-14)

**Screen 11: Current Body Type**
- Title: "Choisissez votre type de corps actuel"
- Progress bar
- 4 female silhouette options in a row: Mince → Légèrement | Moyen | Ample
  * Each is a simple stylized illustration (can be created with SwiftUI shapes or use rectangles with varying widths)
  * Below each: "Masse grasse X-X%" label
  * Selected one is highlighted
- Horizontal slider below the images to select
- Button: "Suivant"

**Screen 12: Target Body Type**
- Title: "Choisissez votre type de corps souhaité ?"
- Same layout as Screen 11
- Button: "Suivant"

**Screen 13: Weight Projection Graph**
- Title: "Nous prévoyons que vous atteindrez 56.1kg d'ici avr. 23"
  * (calculated from userWeight → targetWeight over ~12 weeks)
- Full beautiful curved graph showing weight loss trajectory
- Similar curve to Screen 10 but more detailed
  * Show current weight on left axis
  * Show intermediate milestones as dots
  * Target weight marked with gold dot
- Small BMI note: "Votre IMC : 20.2" / "Vous êtes en excellente forme. Nos recommandations sont basées sur..."
- Button: "Suivant"

**Screen 14: Age**
- Title: "Quel âge as-tu ?"
- Progress bar
- Wheel picker for age (18-80)
  * Center value large: "39"
  * Adjacent values above/below slightly visible and smaller
- Button: "Suivant"

### Phase 5 — Lifestyle & Fitness (Screens 15-20)

**Screen 15: Potential Motivator**
- Title: "Vous avez un grand potentiel pour atteindre vos objectifs !"
- Progress bar
- Emoji row: 💪🔥✨
- Motivational paragraph text
- Button: "Suivant"

**Screen 16: Exercise Location**
- Title: "Où faites-vous habituellement de l'exercice ?"
- Progress bar
- Options (single-select):
  * "Sur le tapis" (mat icon)
  * "Sur le lit / canapé" (bed icon)
  * "Tous les lieux me conviennent" (location pin icon)
- Button: "Suivant"

**Screen 17: Training Type Preference**
- Title: "Quel est ton type d'entraînement préféré ?"
- Progress bar
- Options:
  * "Sans équipement"
  * "Pas de sport"
  * "Exercices alternatifs"
  * "Aucune d'entre eux"
- Button: "Suivant"

**Screen 18: Difficulty Preference**
- Title: "Quel est ton niveau de difficulté d'entraînement préféré ?"
- Progress bar
- Options:
  * "Facile à commencer"
  * "Transpiration légère"
  * "Un peu exigeant"
- Button: "Suivant"

**Screen 19: Injuries**
- Title: "Des zones blessées nécessitant de l'attention ?"
- Progress bar
- Body outline (front view, simple line drawing using SwiftUI Path)
- Tappable zone buttons arranged around the body:
  * "Aucun d'entre eux" (None — deselects others)
  * "Genou" (knee)
  * "Bas du dos" (lower back)
  * "Épaule" (shoulder)
  * "Cheville" (ankle)
- Multi-select
- Button: "Suivant"

**Screen 20: Mini Future Pace**
- Shows: "56.1kg d'ici avr. 04"
- Big bold stat: "19 jours à l'avance !"
- Sub-text: "Nos données montrent que pour les femmes dans votre tranche d'âge, une bonne alimentation et de l'exercice après une semaine..."
- Mini graph / progress visual
- Button: "Suivant"

### Phase 6 — Lifestyle Deep Dive (Screens 21-24)

**Screen 21: Daily Life**
- Title: "À quoi ressemble l'une de vos journées types ?"
- Progress bar
- Options:
  * "Au travail, principalement assis"
  * "À la maison, principalement inactive"
  * "Marcher les jours"
  * "Travailler principalement debout"
- Button: "Suivant"

**Screen 22: Activity Level**
- Title: "Choisissez votre niveau d'activité"
- Progress bar
- Options with illustrated characters (use simple SF Symbol figures):
  * "Inactive" — illustration of sedentary person
  * "Légèrement active"
  * "Très active"
- Selected option shows a bigger illustration + description label
- Button: "Suivant"

**Screen 23: Fitness Level**
- Title: "Quel est votre niveau de forme physique ?"
- Progress bar
- Options with illustrated characters:
  * "Débutante" — illustration of beginner pilates
  * "Intermédiaire"
  * "Avancée"
- Button: "Suivant"

**Screen 24: Mid-Funnel Social Proof**
- Title: "Nous avons aidé 87,965+ personnes comme vous à atteindre leurs objectifs !"
- Progress bar
- Large photo/illustration of woman doing pilates (use a placeholder colored rectangle with pilates SF symbol)
- Testimonial quote
- Button: "Suivant"

### Phase 7 — Physical Assessment (Screens 25-26)

**Screen 25: Flexibility Test**
- Title: "Jusqu'où pouvez-vous faire une flexion avant assise ?"
- Progress bar
- Animated illustration showing the seated forward bend (use a simple SF Symbol animation or static image)
- Options:
  * "Essoufflée" (can't reach)
  * "Loin de mes pieds"
  * "Près de mes pieds"
  * "Toucher facilement"
- Button: "Suivant"

**Screen 26: Cardio Fitness**
- Title: "Comment vous sentez-vous après une marche rapide ?"
- Progress bar
- Options:
  * "Essoufflée"
  * "Légèrement essoufflée"
  * "Complètement à l'aise"
- Button: "Suivant"

### Phase 8 — Cognitive Behavioral (Screens 27-30)

Each screen format:
- Title: "Vous identifiez-vous à l'affirmation ci-dessous ?"
- Large quote/affirmation text in center
- Bottom: Two buttons side by side — "Non ✗" (light/outline) | "Oui ✓" (dark filled)

**Screen 27: Affirmation 1**
"Je ne sais pas comment choisir les bons entraînements pour moi."

**Screen 28: Affirmation 2**
"J'abandonne souvent lorsque les entraînements sont trop difficiles ou que je ne suis pas motivée."

**Screen 29: Affirmation 3**
"J'abandonne souvent quand je manque de motivation externe ou que je ne suis pas dans un bon état d'esprit."

**Screen 30: Affirmation 4**
"Faire de l'exercice dans le cadre d'une solide routine m'aiderait à m'entraîner efficacement seule."

### Phase 9 — Emotional Anchoring (Screens 31-34)

**Screen 31: Social Proof — 100k**
- Title: "Le Pilates a aidé plus de 100k personnes comme vous !"
- Big stat: "100k+" in gold/accent color
- Sub: "97.5% des utilisatrices ont constaté des changements visibles grâce à notre plan de Pilates suivi à 30 jours!"
- Pilates logo or brand mark at center
- Button: "Suivant"

**Screen 32: Reward Visualization**
- Title: "Quelle est votre récompense pour avoir atteint votre objectif de poids ?"
- Progress bar
- Options (multi-select):
  * "Acheter de nouveaux vêtements" 👗
  * "Profitez d'un repas délicieux" 🍽️
  * "Faire un cadeau à moi-même" 🎁
  * "Partir en voyage" ✈️
  * "Prendre des photos attractives" 📸
  * "Organiser des fêtes avec des amis" 🎉
- Button: "Suivant"

**Screen 33: Emotional Visualization**
- Title: "Comment vous sentiriez-vous lorsque vous atteindrez votre poids idéal ?"
- Progress bar
- Options (multi-select):
  * "Ce serait excellent !"
  * "Satisfaite de mon corps"
  * "Fière de moi-même"
  * "Pleine d'énergie"
  * "Meilleure santé"
- Button: "Suivant"

**Screen 34: Face Transformation**
- Title: "Découvrez comment la perte de poids peut remodeler votre visage"
- Progress bar
- Side-by-side comparison (before/after)
  * Weight labels: "70kg" | "60kg" with arrow or gradient separator
  * Use placeholder images or illustrated faces
- Motivational text below about facial changes from weight loss
- Button: "Suivant"

### Phase 10 — Full-Screen Affirmation Questions (Screens 35-37)

Each screen:
- FULL BLEED background image (beautiful woman exercising — use gradient placeholder)
- Title overlaid on top with a semi-transparent blur behind text
- Two buttons at bottom:
  * "Oui" — filled dark/gold
  * "Incertain" — outlined/ghost

**Screen 35: "Voulez-vous perdre du poids ?"**
**Screen 36: "Voulez-vous sculpter un corps attractif ?"**
**Screen 37: "Voulez-vous être libérée de maladies chroniques ?"**

### Phase 11 — Facading & Conversion (Screens 38-40)

**Screen 38: Loading/Facading**
- Background: Champagne blush
- Center: Large circular progress ring (animated from 0% to 100%)
- Big stat: "300 000+ Séances de Pilates ont été complétées ici !"
- Animated text cycling through:
  * "Analyse de votre profil..."
  * "Alignement de vos objectifs..."
  * "Création de votre calendrier personnalisé..."
  * "Calcul des contraintes biomécaniques..."
- Takes 4-5 seconds with smooth animation
- Auto-advances when complete

**Screen 39: Final Projection**
- Title: "Tu pèseras 56.1 kg d'ici le avr. 4"
  * (dynamically calculated from user data)
- Beautiful weight loss graph (best one in the whole flow, most detailed)
- Shows current weight → goal weight curve with date markers
- Small "Objectif facile" badge in green
- Below graph: Summary stats (current BMI, goal BMI)
- BIG CTA button: "Obtenez votre programme personnalisé !"
  * This button is GOLD (#DDB263), large, full-width, strong shadow

**Screen 40: Paywall**
- Title: "Routine De Remise En Forme"
- Shows a preview of the 30-day calendar (mini calendar grid)
- Plan details: Routine de Remise En Forme, dates shown
- Subscription options:
  * Annual: "12 mois - €39.99" with "POPULAIRE" badge
  * Monthly: "1 mois - €9.99"
- 3-day free trial badge
- "Continuer" button (gold, full width)
- Privacy links at bottom
- "Restaurer l'achat" link

## KEY UI PATTERNS TO IMPLEMENT

### Selection Card Style (used throughout):
```swift
// Standard selection option card
RoundedRectangle(cornerRadius: 16)
    .fill(isSelected ? Color.white.opacity(0.95) : Color.white.opacity(0.5))
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(isSelected ? Color(hex: "E8B6C3") : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
    )
// Left: icon + text, Right: checkmark (only when selected)
```

### Progress Bar (top of screen):
```swift
// Thin progress bar at very top, full width, pink/gold gradient
GeometryReader { geo in
    RoundedRectangle(cornerRadius: 2)
        .fill(Color(hex: "E8B6C3"))
        .frame(width: geo.size.width * progress, height: 4)
}
.background(Color(hex: "E6C7B2").opacity(0.3))
.frame(height: 4)
```

### Weight/Height Wheel Picker:
```swift
// Use Picker with .wheel style but styled
// The center value shows very large
Picker("Height", selection: $heightCm) {
    ForEach(140...200, id: \.self) { h in
        Text("\(h)").tag(h)
    }
}
.pickerStyle(.wheel)
```

### Primary Button Style:
```swift
// Dark charcoal button (most screens)
.background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "3A2A2F")))
.foregroundColor(.white)

// Gold CTA (final screens only)
.background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "DDB263")))
```

### Back Navigation:
- Each screen (except Screen 1) has a "<" back arrow in top-left
- No navigation bar, custom back button

## ONBOARDING DATA MODEL
```swift
class OnboardingData: ObservableObject {
    @Published var motivation: String = ""
    @Published var familiarity: String = ""
    @Published var mainGoal: String = ""
    @Published var focusAreas: Set<String> = []
    @Published var heightCm: Int = 165
    @Published var currentWeightKg: Double = 65.0
    @Published var targetWeightKg: Double = 60.0
    @Published var currentBodyType: Int = 1 // 0-3 index
    @Published var targetBodyType: Int = 0
    @Published var age: Int = 30
    @Published var exerciseLocation: String = ""
    @Published var trainingType: String = ""
    @Published var difficulty: String = ""
    @Published var injuries: Set<String> = []
    @Published var dailyLife: String = ""
    @Published var activityLevel: String = ""
    @Published var fitnessLevel: String = ""
    @Published var flexibility: String = ""
    @Published var cardioFitness: String = ""
    @Published var affirmation1: Bool? = nil
    @Published var affirmation2: Bool? = nil
    @Published var affirmation3: Bool? = nil
    @Published var affirmation4: Bool? = nil
    @Published var rewards: Set<String> = []
    @Published var emotionalGoals: Set<String> = []
    @Published var vousPerdre: Bool = true
    @Published var vousScupter: Bool = true
    @Published var vousLibere: Bool = true

    // Computed
    var weightDelta: Double { currentWeightKg - targetWeightKg }
    var targetDateString: String {
        let date = Calendar.current.date(byAdding: .weekOfYear, value: 12, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
```
