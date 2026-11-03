import SwiftUI

struct TrainRootView: View {
    let composition: AppComposition
    @Binding var path: [TrainRoute]
    let onSessionSaved: () -> Void
    @State private var viewModel: TrainViewModel
    @State private var selectedExercise: ExerciseSnapshot?
    @State private var activeWorkout: ActiveWorkoutViewModel?

    init(composition: AppComposition, path: Binding<[TrainRoute]>, onSessionSaved: @escaping () -> Void) {
        self.composition = composition
        _path = path
        self.onSessionSaved = onSessionSaved
        _viewModel = State(initialValue: composition.train())
    }

    var body: some View {
        NavigationStack(path: $path) {
            TrainView(
                viewModel: viewModel,
                showSettings: { path.append(.settings) },
                showMusclePicker: { path.append(.creation) },
                showSessionBuilder: { path.append(.sessionBuilder(workoutID: $0)) },
                onStartWorkout: { activeWorkout = composition.active(workoutID: $0) },
                onOverview: { activeWorkout = composition.active(workoutID: $0) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TrainRoute.self) { route in
                switch route {
                case .creation:
                    WorkoutCreationView(onManual: { path.append(.sessionBuilder(workoutID: nil)) },
                                        onSmart: { path.append(.musclePicker) })
                case .overview(let id):
                    WorkoutOverviewView(viewModel: composition.overview(workoutID: id),
                                        onEdit: { path.append(.sessionBuilder(workoutID: id)) },
                                        onStart: { activeWorkout = composition.active(workoutID: id) },
                                        onExercise: { selectedExercise = $0; path.append(.guide(exerciseID: $0.id)) })
                case .guide(let id):
                    if let selectedExercise, selectedExercise.id == id {
                        MovementDetailView(viewModel: composition.movement(selectedExercise), backLabel: String(localized: .uiDesignOverview))
                    } else {
                        Text(.uiMovementUnavailable).foregroundStyle(Theme.text2)
                    }
                case .settings:
                    SettingsView(viewModel: composition.settings(), onNotifications: { path.append(.notifications) })
                case .notifications:
                    NotificationsView(viewModel: composition.notifications())
                case .musclePicker:
                    MusclePickerView(viewModel: MusclePickerViewModel(), onBuild: { targets in
                        path.append(.sessionBuilder(workoutID: nil, targetMuscleGroups: targets))
                    }, onSkip: { path.append(.sessionBuilder(workoutID: nil)) })
                case .sessionBuilder(let id, let targets):
                    SessionBuilderView(
                        viewModel: composition.builder(workout: nil, targets: targets, workoutID: id),
                        makeMovement: composition.movement,
                        onSaved: {
                            if path.contains(where: { if case .overview = $0 { return true }; return false }) {
                                path.removeLast()
                            } else { path = [] }
                        },
                        onDeleted: { path = [] }
                    )
                }
            }
        }
        .onChange(of: path) { _, value in
            if value.isEmpty { Task { await viewModel.load() } }
        }
        .fullScreenCover(isPresented: Binding(get: { activeWorkout != nil }, set: { if !$0 { dismissWorkout() } })) {
            if let activeWorkout {
                ActiveWorkoutRootView(composition: composition, viewModel: activeWorkout, onEnd: dismissWorkout)
                    .interactiveDismissDisabled()
            }
        }
    }

    private func dismissWorkout() {
        if activeWorkout?.saveState == .saved { onSessionSaved() }
        activeWorkout?.cleanup()
        activeWorkout = nil
        Task { await viewModel.load() }
    }
}
