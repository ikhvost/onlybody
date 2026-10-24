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

    let jsonData = try Data(contentsOf: URL(fileURLWithPath: seedDataPath))
    let seeds = try JSONDecoder().decode([ExerciseSeed].self, from: jsonData)

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
