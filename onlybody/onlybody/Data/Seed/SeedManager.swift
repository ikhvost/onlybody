import Foundation
import SwiftData

@MainActor
struct SeedManager {
    static func seedIfNeeded(context: ModelContext, bundle: Bundle = .main) {
        var descriptor = FetchDescriptor<Exercise>()
        descriptor.fetchLimit = 1

        guard let existingExercises = try? context.fetch(descriptor), existingExercises.isEmpty else {
            return
        }

        guard let url = bundle.url(forResource: "SeedData", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let seeds = try JSONDecoder().decode([ExerciseSeed].self, from: data)

            for seed in seeds {
                let exercise = Exercise()
                exercise.name = seed.name
                exercise.primaryMuscle = seed.primaryMuscle
                exercise.secondaryMuscles = seed.secondaryMuscles
                exercise.equipment = seed.equipment
                exercise.frequencyPreference = seed.frequencyPreference
                exercise.isCustom = seed.isCustom
                context.insert(exercise)
            }

            try context.save()
        } catch {
            return
        }
    }
}
