import SwiftUI

struct ActiveWorkoutRootView: View {
    let composition: AppComposition
    let viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void
    @State private var path: [ActiveWorkoutRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ActiveWorkoutView(
                viewModel: viewModel,
                onEnd: onEnd,
                onGuide: { path.append(.guide(exerciseID: $0.id)) },
                onHistory: { path.append(.history(exerciseName: $0)) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ActiveWorkoutRoute.self) { route in
                switch route {
                case .guide(let exerciseID):
                    if let exercise = viewModel.items.compactMap(\.exercise).first(where: { $0.id == exerciseID }) {
                        MovementDetailView(viewModel: composition.movement(exercise), backLabel: String(localized: .uiBackToWorkout))
                    }
                case .history(let exerciseName):
                    ExerciseHistoryView(viewModel: composition.exerciseHistory(exerciseName: exerciseName))
                }
            }
        }
    }
}
