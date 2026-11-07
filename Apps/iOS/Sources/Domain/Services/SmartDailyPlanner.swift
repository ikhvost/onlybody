import Foundation

/// Resolves a local-day cache before generating. Persistence is injected and never changes a template implicitly.
@MainActor
struct SmartDailyPlanner {
    let variants: any SmartDailyVariantRepository
    var clock = SmartPlanningClock()

    func resolve(workout: WorkoutSnapshot, settings: SmartWorkoutSettings, exercises: [ExerciseSnapshot],
                 date: Date) async throws -> SmartDailyVariant {
        let day = clock.localDay(at: date)
        if let existing = try await variants.variant(workoutID: workout.id, localDay: day, settingsRevision: settings.revision) {
            return existing
        }
        let previous = try await variants.latestVariant(workoutID: workout.id)
        let result = SmartSelectionGenerator().plan(configuration: settings.configuration, from: exercises,
            context: SmartGenerationContext(mainExerciseNames: settings.mainExerciseNames,
                previousExerciseNames: previous?.items.compactMap { $0.exercise?.name } ?? [],
                variationSeed: clock.variationSeed(workoutID: workout.id, localDay: day)))
        return SmartDailyVariant(workoutID: workout.id, localDay: day, settingsRevision: settings.revision,
                                 items: result.items, estimatedSeconds: result.estimatedSeconds,
                                 uncoveredNeeds: result.uncoveredNeeds, createdAt: date)
    }
}
