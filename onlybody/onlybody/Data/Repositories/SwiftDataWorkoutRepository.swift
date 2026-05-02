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

    func workout(by id: UUID) async throws -> Workout? {
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
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

    func deleteItems(_ items: [WorkoutItem]) async throws {
        for item in items {
            context.delete(item)
        }
        try context.save()
    }
}
