import Foundation
import UIKit

/// The app-level factory is the only layer wiring repositories to screens.
@MainActor
struct AppComposition {
    let configuration: AppConfiguration
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository
    let preferences: WorkoutPreferences
    let reminders: WorkoutReminderCoordinator

    func train() -> TrainViewModel { TrainViewModel(workouts: workouts, appName: configuration.displayName) }
    func log() -> LogViewModel { LogViewModel(sessions: sessions) }
    func library() -> LibraryViewModel { LibraryViewModel(exercises: exercises) }
    func settings() -> SettingsViewModel {
        SettingsViewModel(
            appName: configuration.displayName,
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—",
            preferences: preferences
        )
    }
    func builder(workout: WorkoutSnapshot?, targets: [String]) -> SessionBuilderViewModel {
        SessionBuilderViewModel(
            workouts: workouts, exercises: exercises, workout: workout, targetMuscleGroups: targets,
            generator: SmartWorkoutGenerator(fallbackPolicy: configuration.workoutFallback),
            onScheduleChanged: { await reminders.refresh() }
        )
    }
    func notifications() -> NotificationsViewModel {
        NotificationsViewModel(preferences: preferences, reminders: reminders, openSystemSettings: {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return false }
            return await UIApplication.shared.open(url)
        })
    }
    func active(workoutID: UUID) -> ActiveWorkoutViewModel {
        let cue = WorkoutCuePlayer()
        return ActiveWorkoutViewModel(
            workouts: workouts, sessions: sessions, workoutId: workoutID,
            preferences: preferences,
            playRestCue: { cue.play() }, stopRestCue: { cue.stop() }
        )
    }
    func exerciseHistory(exerciseName: String) -> ExerciseHistoryViewModel {
        ExerciseHistoryViewModel(exerciseName: exerciseName, sessions: sessions, preferences: preferences)
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
