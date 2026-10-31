#if DEBUG
import Foundation
import SwiftData

/// Populates only explicitly requested, UUID-isolated screenshot stores with fictional training history.
@MainActor
enum ScreenshotStoreFixture {
    static func populateIfRequested(_ container: ModelContainer, product: String) throws {
        let environment = ProcessInfo.processInfo.environment
        guard environment["ONLYBODY_SCREENSHOT_FIXTURE"] == "populated",
              environment["ONLYBODY_UI_FIXTURE"] == "catalog",
              environment["ONLYBODY_UI_STORE"].flatMap(UUID.init(uuidString:)) != nil else { return }
        try populate(container, product: product, language: environment["ONLYBODY_SCREENSHOT_LANGUAGE"] ?? "en")
    }

    static func populate(_ container: ModelContainer, product: String, language: String, today: Date = .now) throws {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        guard try context.fetchCount(FetchDescriptor<Workout>()) == 0,
              try context.fetchCount(FetchDescriptor<Session>()) == 0 else { return }
        let catalog = try context.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)]))
        let isWeights = product == "OnlyWeights"
        let selections = isWeights ? [
            ["Barbell Bench Press", "Lat Pulldown", "Dumbbell Shoulder Press", "Dumbbell Curl"],
            ["Barbell Back Squat", "Barbell Romanian Deadlift", "Leg Extension", "Standing Calf Raise"],
            ["Seated Cable Row", "Incline Dumbbell Press", "Cable Face Pull", "Cable Triceps Pushdown"],
            ["Leg Press", "Seated Leg Curl", "Dumbbell Lateral Raise", "Lat Pulldown"]
        ] : [
            ["Standard Push-Ups", "Inverted Rows", "Pike Push-Ups", "Bird Dog"],
            ["Squats", "Reverse Lunges", "Glute Bridge", "Calf Raises"],
            ["Incline Push-Ups", "Superman", "Bird Dog", "Dead Bug"],
            ["Pull-Ups", "Standard Push-Ups", "Bulgarian Split Squats", "Glute Bridge"]
        ]
        let localizedNames = [
            "en": ["Upper Body", "Legs & Glutes", "Core & Balance", "Full Body"],
            "uk": ["Верх тіла", "Ноги та сідниці", "Кор і баланс", "Усе тіло"],
            "pl": ["Góra ciała", "Nogi i pośladki", "Core i równowaga", "Całe ciało"],
            "de": ["Oberkörper", "Beine & Gesäß", "Rumpf & Balance", "Ganzkörper"],
            "fr": ["Haut du corps", "Jambes et fessiers", "Centre et équilibre", "Corps entier"]
        ]
        var names = localizedNames[language] ?? localizedNames["en"] ?? []
        if isWeights {
            let pullNames = ["en": "Back & Arms", "uk": "Спина та руки", "pl": "Plecy i ramiona",
                             "de": "Rücken & Arme", "fr": "Dos et bras"]
            names[2] = pullNames[language] ?? "Back & Arms"
        }
        let todayIndex = Calendar.current.component(.weekday, from: today) - 1
        var workouts: [Workout] = []
        for (index, selectedNames) in selections.enumerated() {
            let workout = Workout()
            workout.name = names[index]
            workout.mode = WorkoutMode.manual.rawValue
            workout.scheduledDays = [Weekdays.shortNames[(todayIndex + index * 2) % 7]]
            workout.restSeconds = isWeights ? 90 : 45
            workout.durationMinutes = 30 + index * 5
            context.insert(workout)
            let selected = selectedNames.compactMap { name in catalog.first { $0.name == name } }
            workout.items = selected.enumerated().map { order, exercise in
                let item = WorkoutItem()
                item.order = order
                item.exercise = exercise
                item.workout = workout
                item.sets = 3
                item.targetReps = isWeights ? 10 : 12
                item.restSeconds = workout.restSeconds ?? 45
                return item
            }
            workouts.append(workout)
        }
        // Three sessions per week across 18 weeks, plus yesterday for a three-day current streak.
        var offsets = [1]
        for week in 0..<18 { offsets.append(contentsOf: [week * 7, week * 7 + 2, week * 7 + 4]) }
        offsets.sort()
        for (index, offset) in offsets.enumerated() {
            let workout = workouts[index % workouts.count]
            let session = Session()
            session.date = Calendar.current.date(byAdding: .day, value: -offset, to: today) ?? today
            session.durationSeconds = 1_620 + (index % 7) * 123
            session.workoutName = workout.name
            context.insert(session)
            let plannedItems: [WorkoutItem] = workout.items ?? []
            session.items = plannedItems.sorted(by: { $0.order < $1.order }).map { planned in
                let item = SessionItem()
                item.order = planned.order
                item.exerciseName = planned.exercise?.name ?? ""
                item.plannedSets = planned.sets
                item.plannedReps = planned.targetReps
                let reps = planned.targetReps - min(index / 18, 2)
                item.setReps = [reps, reps, max(reps - 1, 1)]
                if isWeights {
                    let weight = Double(50 - planned.order * 10 - min(index / 9, 5) * 2)
                    item.weightKg = weight
                    item.setWeightsKg = [weight, weight, weight]
                }
                return item
            }
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
#endif
