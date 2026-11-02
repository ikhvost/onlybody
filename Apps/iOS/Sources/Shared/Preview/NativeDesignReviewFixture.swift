#if DEBUG
import Foundation
import SwiftUI

/// Frozen, in-memory view fixtures for rendering at the three approved design widths.
@MainActor
struct NativeDesignReviewFixture {
    let train: TrainViewModel
    let emptyTrain: TrainViewModel
    let builder: SessionBuilderViewModel
    let active: ActiveWorkoutViewModel
    let library: LibraryViewModel
    let log: LogViewModel
    let overview: WorkoutOverviewViewModel
    let history: ExerciseHistoryViewModel
    let settings: SettingsViewModel
    let notifications: NotificationsViewModel
    let exercise: ExerciseSnapshot
    let session: SessionSnapshot

    init() async {
        let date = Date(timeIntervalSince1970: 1_793_404_800)
        #if ONLYWEIGHTS
        let name = "Barbell Bench Press"
        #else
        let name = "Standard Push-Ups"
        #endif
        exercise = ExerciseSnapshot(name: name, primaryMuscle: "Chest", secondaryMuscles: ["Triceps", "Shoulders"], equipment: ["None"])
        let item = WorkoutItemSnapshot(sets: 3, targetReps: 12, restSeconds: 45, exercise: exercise)
        let workout = WorkoutSnapshot(name: "Full Body · Ganzkörper · Entraînement complet", mode: "manual", scheduledDays: ["Sat"], items: [item])
        let workouts = PreviewWorkoutRepository(workouts: [workout])
        let exercises = PreviewExerciseRepository(exercises: [exercise])
        var completed = SessionItemSnapshot()
        completed.exerciseName = name
        completed.setReps = [12, 10]
        completed.setWeightsKg = [0, 2.5]
        session = SessionSnapshot(date: date, durationSeconds: 240, workoutName: workout.name, items: [completed])
        let sessions = PreviewSessionRepository(sessions: [session])
        let preferences = WorkoutPreferences()
        train = TrainViewModel(workouts: workouts, appName: AppConfiguration.current.displayName, now: { date })
        emptyTrain = TrainViewModel(workouts: PreviewWorkoutRepository(), appName: AppConfiguration.current.displayName, now: { date })
        builder = SessionBuilderViewModel(workouts: workouts, exercises: exercises, workout: workout)
        active = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id,
                                        time: PreviewWorkoutTimeSource(now: date), alwaysShowsWeight: AppConfiguration.current.alwaysShowsWeight)
        library = LibraryViewModel(exercises: exercises)
        log = LogViewModel(sessions: sessions, now: { date })
        overview = WorkoutOverviewViewModel(workoutID: workout.id, workouts: workouts)
        history = ExerciseHistoryViewModel(exerciseName: name, sessions: sessions)
        settings = SettingsViewModel(appName: AppConfiguration.current.displayName, version: "Preview", preferences: preferences)
        let reminders = WorkoutReminderCoordinator(preferences: preferences, workouts: workouts, notifications: PreviewWorkoutNotificationClient())
        notifications = NotificationsViewModel(preferences: preferences, reminders: reminders)
        await train.load()
        await emptyTrain.load()
        await builder.loadExercises()
        await active.load()
        active.beginSession()
        await library.load()
        await log.load()
        await overview.load()
        await history.load()
    }

    @ViewBuilder func screen(_ index: Int) -> some View {
        switch index / 5 {
        case 0: creationScreen(index)
        case 1: activeScreen(index)
        case 2: historyScreen(index)
        default: informationScreen(index)
        }
    }

    @ViewBuilder private func creationScreen(_ index: Int) -> some View {
        switch index {
        case 0: TrainView(viewModel: train, showSettings: {}, showMusclePicker: {}, showSessionBuilder: { _ in }, onStartWorkout: { _ in })
        case 1: TrainView(viewModel: emptyTrain, showSettings: {}, showMusclePicker: {}, showSessionBuilder: { _ in }, onStartWorkout: { _ in })
        case 2: WorkoutCreationView(onManual: {}, onSmart: {})
        case 3: MusclePickerView(viewModel: MusclePickerViewModel(), onBuild: { _ in }, onSkip: {})
        default: SessionBuilderView(viewModel: builder)
        }
    }

    @ViewBuilder private func activeScreen(_ index: Int) -> some View {
        switch index {
        case 5: BuilderMovementEditor(viewModel: builder, movementID: builder.movements.first?.id ?? UUID())
        case 6: ExercisePickerView(viewModel: ExercisePickerViewModel(exercises: [exercise]), onAdd: { _ in })
        case 7: ActiveWorkoutContentView(viewModel: active, onGuide: {}, onHistory: {})
        case 8: ActiveWorkoutContentView(viewModel: active, onGuide: {}, onHistory: {})
                .onAppear { active.restTimer.start(seconds: 35) }
        default: ActiveWorkoutCompletionView(elapsedString: "04:00", completedSets: 2, saveState: .saved, onRetry: {}, errorMessage: nil, onEnd: {})
        }
    }

    @ViewBuilder private func historyScreen(_ index: Int) -> some View {
        switch index {
        case 10: ActiveWorkoutCompletionView(elapsedString: "04:00", completedSets: 2, saveState: .failed,
                                           onRetry: {}, errorMessage: String(localized: .uiCouldNotSaveSession), onEnd: {})
        case 11: ExerciseHistoryView(viewModel: history)
        case 12: LogView(viewModel: log, showSessionDetail: { _ in })
        case 13: SessionDetailView(viewModel: SessionDetailViewModel(session: session))
        default: LibraryView(viewModel: library, showMovement: { _ in })
        }
    }

    @ViewBuilder private func informationScreen(_ index: Int) -> some View {
        switch index {
        case 15: MovementDetailView(viewModel: MovementDetailViewModel(exercise: exercise, allowsVideoLoading: false))
        case 16: SettingsView(viewModel: settings, onNotifications: {})
        case 17: NotificationsView(viewModel: notifications)
        case 18: ActiveWorkoutSessionList(viewModel: active, onClose: {}, onEnd: {})
        default: ExerciseFilterSheet(muscle: .constant("Chest"), equipment: .constant("None"), equipmentOptions: ["None", "Dumbbells"])
        }
    }
}
#endif
