import SwiftUI

struct TrainRootView: View {
    let composition: AppComposition
    @Environment(\.scenePhase) private var scenePhase
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
                showSessionBuilder: { openWorkout($0, editing: true) },
                onStartWorkout: { openWorkout($0, editing: false) },
                onOverview: { openWorkout($0, editing: false) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TrainRoute.self) { route in
                switch route {
                case .smart(let id, let targets, let opensPreview):
                    SmartSelectionView(viewModel: composition.smart(workoutID: id, targets: targets, opensPreview: opensPreview),
                        makeBuilder: composition.dailyBuilder, makeMovement: composition.movement, onSaved: { path = [] }, onStart: { workout in
                            path = []
                            activeWorkout = composition.active(workoutID: workout.id, reviewedWorkout: workout)
                        })
                case .creation:
                    WorkoutCreationView(onManual: { path.append(.sessionBuilder(workoutID: nil)) },
                                        onSmart: { path.append(.smart(workoutID: nil)) })
                case .overview(let id):
                    WorkoutOverviewView(viewModel: composition.overview(workoutID: id),
                                        onEdit: { openWorkout(id, editing: true) },
                                        onStart: { openWorkout(id, editing: false) },
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
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await viewModel.load() } }
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

    private func openWorkout(_ id: UUID?, editing: Bool) {
        guard let id else { path.append(.sessionBuilder(workoutID: nil)); return }
        if viewModel.workouts.first(where: { $0.id == id })?.mode == WorkoutMode.smart.rawValue {
            path.append(.smart(workoutID: id, opensPreview: true))
        } else if editing { path.append(.sessionBuilder(workoutID: id)) } else { activeWorkout = composition.active(workoutID: id) }
    }

    private func dismissWorkout() {
        if activeWorkout?.saveState == .saved { onSessionSaved() }
        activeWorkout?.cleanup()
        activeWorkout = nil
        Task { await viewModel.load() }
    }
}
