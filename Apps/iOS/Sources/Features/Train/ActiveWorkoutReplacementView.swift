import SwiftUI

struct ActiveWorkoutReplacementView: View {
    let viewModel: ActiveWorkoutViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let itemID: UUID
    @State private var isReady = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.space12) {
            if !isReady || viewModel.isLoadingExercises {
                ProgressView().tint(Theme.accent)
            } else if let error = viewModel.replacementError {
                Text(error).foregroundStyle(Theme.text2)
                GhostButton(title: String(localized: .uiRetry)) { Task { await viewModel.loadReplacementExercises() } }
                GhostButton(title: String(localized: .uiCancel)) { dismiss() }
            } else if let configuration = viewModel.smartConfiguration, let item = viewModel.items.first(where: { $0.id == itemID }) {
                SmartReplacementView(viewModel: SmartReplacementViewModel(item: item, items: viewModel.items,
                    configuration: configuration, catalog: viewModel.allExercises), makeMovement: makeMovement,
                    onReplace: { exercise in viewModel.replaceExercise(itemID, with: exercise) },
                    onExclude: {
                        guard let exercise = item.exercise else { return false }
                        return await viewModel.excludeFromFuture(exercise)
                    })
            } else {
                ExercisePickerView(viewModel: ExercisePickerViewModel(exercises: viewModel.allExercises), makeMovement: makeMovement,
                                   title: String(localized: .uiWorkoutReplace)) { exercise in
                    viewModel.replaceExercise(itemID, with: exercise)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.bg)
        .task { await viewModel.loadReplacementExercises(); isReady = true }
    }
}
