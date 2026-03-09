import Foundation

// MARK: - Day Session

struct DaySession: Identifiable {
    let id: Int // Day number 1-30
    let exercises: [PilatesExercise]
    let totalDuration: Int // seconds
    var isCompleted: Bool = false
    var isUnlocked: Bool

    var durationMinutes: Int { totalDuration / 60 }
    var title: String { "Jour \(id)" }
    var subtitle: String { exercises.first?.name ?? "Pilates" }
}

// MARK: - Workout Plan Generator

struct WorkoutPlan {

    /// Generate a progressive 30-day Pilates challenge plan.
    /// Days 1-7: Beginner (10-12 min, foundation + wall pilates)
    /// Days 8-14: Intermediate intro (12-15 min, classical exercises added)
    /// Days 15-21: Building intensity (15-18 min, full body focus)
    /// Days 22-30: Advanced finishing strong (18-20 min, all modalities)
    static func generate30DayPlan(completedDay: Int = 0, daysSinceStart: Int = 0) -> [DaySession] {
        let all = ExerciseCatalog.all30DayChallenge
        let wall = ExerciseCatalog.wallPilates
        var sessions: [DaySession] = []

        for day in 1...30 {
            let maxUnlockedDayByTime = daysSinceStart + 1
            let isUnlocked = (day <= completedDay + 1) && (day <= maxUnlockedDayByTime)
            let isCompleted = day <= completedDay

            let dayExercises: [PilatesExercise]
            let totalDuration: Int

            switch day {
            // Week 1: Foundation (3-4 exercises, 10-12 min)
            case 1:
                dayExercises = [all[0], all[1], all[2]] // Breathing, Pelvic Tilt, Glute Bridge
                totalDuration = 10 * 60
            case 2:
                dayExercises = [all[0], all[3], all[4]] // Breathing, Leg Lift, Cat-Cow
                totalDuration = 10 * 60
            case 3:
                dayExercises = [all[1], all[2], all[5]] // Pelvic Tilt, Bridge, Dead Bug
                totalDuration = 10 * 60
            case 4:
                dayExercises = [wall[0], wall[1], wall[3]] // Wall Roll Down, Wall Sit, Wall Push-Ups
                totalDuration = 10 * 60
            case 5:
                dayExercises = [all[0], all[5], all[6], wall[2]] // Breathing, Dead Bug, Spine Stretch, Wall Bridge
                totalDuration = 12 * 60
            case 6:
                dayExercises = [wall[0], wall[1], wall[5], wall[7]] // Wall exercises
                totalDuration = 12 * 60
            case 7:
                dayExercises = [all[1], all[2], all[3], all[5]] // Review day
                totalDuration = 12 * 60

            // Week 2: Classical Introduction (4-5 exercises, 12-15 min)
            case 8:
                dayExercises = [all[7], all[0], all[1], all[2]] // The Hundred + foundation
                totalDuration = 12 * 60
            case 9:
                dayExercises = [all[7], all[8], all[9]] // Hundred, Roll Up, One Leg Circle
                totalDuration = 13 * 60
            case 10:
                dayExercises = [all[8], all[10], all[11]] // Roll Up, Rolling Ball, Single Leg Stretch
                totalDuration = 13 * 60
            case 11:
                dayExercises = [all[7], all[11], all[12], all[6]] // Hundred, Single/Double Leg Stretch, Spine Stretch
                totalDuration = 14 * 60
            case 12:
                dayExercises = [wall[0], wall[1], wall[4], wall[6]] // Wall focus day
                totalDuration = 14 * 60
            case 13:
                dayExercises = [all[7], all[8], all[10], all[13]] // Classical series + Saw
                totalDuration = 15 * 60
            case 14:
                dayExercises = [all[7], all[8], all[9], all[10], all[11]] // Classical review
                totalDuration = 15 * 60

            // Week 3: Intermediate Challenge (5-6 exercises, 15-18 min)
            case 15:
                dayExercises = [all[7], all[14], all[15], all[16]] // Hundred, Swan, Side Kicks, Plank
                totalDuration = 15 * 60
            case 16:
                dayExercises = [all[8], all[13], all[17], all[18]] // Roll Up, Saw, Mermaid, Spine Twist
                totalDuration = 16 * 60
            case 17:
                dayExercises = [all[7], all[14], all[19], all[16], all[15]] // Full body mix
                totalDuration = 16 * 60
            case 18:
                dayExercises = [wall[0], wall[1], wall[4], wall[6], wall[3]] // Intense wall day
                totalDuration = 17 * 60
            case 19:
                dayExercises = [all[7], all[8], all[11], all[12], all[16]] // Classical + plank
                totalDuration = 17 * 60
            case 20:
                dayExercises = [all[14], all[15], all[17], all[19], all[18]] // Flexibility focus
                totalDuration = 18 * 60
            case 21:
                dayExercises = [all[7], all[8], all[9], all[10], all[16], all[13]] // Mid-review
                totalDuration = 18 * 60

            // Week 4+: Advanced Finishing Strong (6-7 exercises, 18-20 min)
            case 22:
                dayExercises = [all[7], all[20], all[16], all[21]] // Hundred, Teaser, Plank, Side Plank
                totalDuration = 18 * 60
            case 23:
                dayExercises = [all[8], all[22], all[24], all[25]] // Roll Up, Boomerang, Scissors, Bicycle
                totalDuration = 18 * 60
            case 24:
                dayExercises = [all[7], all[20], all[23], all[21], all[16]] // Teaser + Push-ups + Planks
                totalDuration = 19 * 60
            case 25:
                dayExercises = [wall[0], wall[1], wall[4], wall[6], wall[2], wall[7]] // Advanced wall
                totalDuration = 19 * 60
            case 26:
                dayExercises = [all[7], all[8], all[20], all[24], all[25], all[26]] // Classical advanced
                totalDuration = 19 * 60
            case 27:
                dayExercises = [all[20], all[21], all[23], all[16], all[22]] // Strength focus
                totalDuration = 20 * 60
            case 28:
                dayExercises = [all[7], all[8], all[9], all[10], all[11], all[12], all[13]] // Classical full series
                totalDuration = 20 * 60
            case 29:
                dayExercises = [all[20], all[22], all[24], all[25], all[26], all[27]] // Advanced series
                totalDuration = 20 * 60
            case 30:
                // Finale: best-of compilation
                dayExercises = [all[7], all[8], all[20], all[16], all[21], all[23], all[27]]
                totalDuration = 20 * 60

            default:
                dayExercises = Array(all.prefix(3))
                totalDuration = 10 * 60
            }

            var session = DaySession(
                id: day,
                exercises: dayExercises,
                totalDuration: totalDuration,
                isUnlocked: isUnlocked
            )
            session.isCompleted = isCompleted
            sessions.append(session)
        }

        return sessions
    }
}
