import Foundation
import SwiftData

@MainActor
func generateStore(outputPath: String, seedDataPath: String) throws {
    let storeURL = URL(fileURLWithPath: outputPath)
    let parentDir = storeURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)

    let config = ModelConfiguration(url: storeURL)
    let container = try ModelContainer(
        for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
        configurations: config
    )
    let context = container.mainContext
    context.autosaveEnabled = false

    let jsonData = try Data(contentsOf: URL(fileURLWithPath: seedDataPath))
    let seeds = try JSONDecoder().decode([ExerciseSeed].self, from: jsonData)

    guard Set(seeds.map(\.name)).count == seeds.count else {
        throw NSError(domain: "StoreGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Duplicate exercise names in seed data."])
    }
    let workoutCount = try context.fetchCount(FetchDescriptor<Workout>())
    let itemCount = try context.fetchCount(FetchDescriptor<WorkoutItem>())
    let sessionCount = try context.fetchCount(FetchDescriptor<Session>())
    let sessionItemCount = try context.fetchCount(FetchDescriptor<SessionItem>())
    guard workoutCount + itemCount + sessionCount + sessionItemCount == 0 else {
        throw NSError(domain: "StoreGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Refusing to replace a store containing user training data."])
    }
    // Regeneration replaces seed rows atomically instead of appending a duplicate catalog.
    for exercise in try context.fetch(FetchDescriptor<Exercise>()) {
        context.delete(exercise)
    }

    for seed in seeds {
        let exercise = Exercise()
        exercise.name = seed.name
        exercise.primaryMuscle = seed.primaryMuscle
        exercise.secondaryMuscles = seed.secondaryMuscles
        exercise.equipment = seed.equipment
        exercise.frequencyPreference = seed.frequencyPreference
        context.insert(exercise)
    }

    try context.save()
    print("Generated store at \(outputPath) with \(seeds.count) exercises.")
}

@MainActor
func main() {
    let args = CommandLine.arguments
    guard args.count == 3 else {
        print("Usage: StoreGenerator <output-store-path> <seed-data-json-path>")
        exit(1)
    }

    do {
        try generateStore(outputPath: args[1], seedDataPath: args[2])
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

main()
