import SwiftUI

struct TrainRootView: View {
    let composition: AppComposition
    @Binding var path: [TrainRoute]
    let onSessionSaved: () -> Void
    @State private var viewModel: TrainViewModel
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
                showMusclePicker: { path.append(.musclePicker) },
                showSessionBuilder: { path.append(.sessionBuilder(workoutID: $0)) },
                onStartWorkout: { activeWorkout = composition.active(workoutID: $0) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TrainRoute.self) { route in
                switch route {
                case .settings:
                    SettingsView(viewModel: composition.settings())
                case .musclePicker:
                    MusclePickerView(viewModel: MusclePickerViewModel(), onBuild: { targets in
                        path.append(.sessionBuilder(workoutID: nil, targetMuscleGroups: targets))
                    }, onSkip: { path.append(.sessionBuilder(workoutID: nil)) })
                case .sessionBuilder(let id, let targets):
                    SessionBuilderView(
                        viewModel: composition.builder(workout: viewModel.workouts.first { $0.id == id }, targets: targets),
                        onSaved: { path = [] }
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
