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
    func exerciseHistory(exerciseName: String) -> ExerciseHistoryViewModel {
        ExerciseHistoryViewModel(exerciseName: exerciseName, sessions: sessions)
    }
    func movement(_ exercise: ExerciseSnapshot) -> MovementDetailViewModel {
        var allowsVideoLoading = true
        var localPlayerDocument: YouTubeEmbedDocument?
        #if DEBUG
        let environment = ProcessInfo.processInfo.environment
        let isPreview = environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        let isOfflineUITest = ["ready", "web"].contains(environment["ONLYBODY_DEMONSTRATION_FIXTURE"] ?? "")
            && environment["ONLYBODY_UI_FIXTURE"] == "catalog"
            && environment["ONLYBODY_UI_STORE"].flatMap(UUID.init(uuidString:)) != nil
        allowsVideoLoading = !isPreview && !isOfflineUITest
        if isOfflineUITest && environment["ONLYBODY_DEMONSTRATION_FIXTURE"] == "web" {
            localPlayerDocument = .localFixture
        }
        #endif
        return MovementDetailViewModel(
            exercise: exercise,
            demonstration: ExerciseDemonstrationCatalog.demonstration(for: exercise.name),
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            allowsVideoLoading: allowsVideoLoading,
            localPlayerDocument: localPlayerDocument,
            network: SystemNetworkAvailabilitySource()
        )
    }
}
