import Foundation
import Observation

/// Loads one saved template and derives its muscle summary without writing data.
@MainActor @Observable
final class WorkoutOverviewViewModel {
    private let repository: any WorkoutRepository
    let workoutID: UUID
    private(set) var workout: WorkoutSnapshot?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var summary: WorkoutMuscleSummary { WorkoutMuscleSummaryCalculator().calculate(items: workout?.items ?? []) }
    var items: [WorkoutItemSnapshot] { (workout?.items ?? []).sorted { $0.order < $1.order } }

    init(workoutID: UUID, workouts: any WorkoutRepository) {
        self.workoutID = workoutID
        repository = workouts
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { workout = try await repository.workout(by: workoutID) } catch { errorMessage = String(localized: .uiCouldNotLoadWorkout) }
    }
}
