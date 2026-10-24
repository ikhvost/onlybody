import Foundation

/// The app-level factory is the only layer wiring repositories to screens.
@MainActor
struct AppComposition {
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository

    func train() -> TrainViewModel { TrainViewModel(workouts: workouts) }
    func log() -> LogViewModel { LogViewModel(sessions: sessions) }
    func library() -> LibraryViewModel { LibraryViewModel(exercises: exercises) }
    func streak() -> StreakViewModel { StreakViewModel(sessions: sessions) }
    func builder(workout: WorkoutSnapshot?, targets: [String]) -> SessionBuilderViewModel {
        SessionBuilderViewModel(workouts: workouts, exercises: exercises, workout: workout, targetMuscleGroups: targets)
    }
    func active(workoutID: UUID) -> ActiveWorkoutViewModel {
        ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workoutID)
    }
    func movement(_ exercise: ExerciseSnapshot) -> MovementDetailViewModel {
        var allowsVideoLoading = true
        #if DEBUG
        let environment = ProcessInfo.processInfo.environment
        let isPreview = environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        let isOfflineUITest = environment["ONLYBODY_DEMONSTRATION_FIXTURE"] == "ready"
            && environment["ONLYBODY_UI_FIXTURE"] == "catalog"
            && environment["ONLYBODY_UI_STORE"].flatMap(UUID.init(uuidString:)) != nil
        allowsVideoLoading = !isPreview && !isOfflineUITest
        #endif
        return MovementDetailViewModel(
            exercise: exercise,
            demonstration: ExerciseDemonstrationCatalog.demonstration(for: exercise.name),
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            allowsVideoLoading: allowsVideoLoading,
            network: SystemNetworkAvailabilitySource()
        )
    }
}
