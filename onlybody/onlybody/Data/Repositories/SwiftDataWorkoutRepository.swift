import Foundation
import SwiftData

@MainActor
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\Workout.name)])
        return try context.fetch(descriptor)
    }

    func save(_ workout: Workout) async throws {
        if workout.modelContext == nil {
            context.insert(workout)
        }

        try context.save()
    }

    func delete(_ workout: Workout) async throws {
        context.delete(workout)
        try context.save()
    }
}
