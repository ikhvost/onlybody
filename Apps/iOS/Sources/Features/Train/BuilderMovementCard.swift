import SwiftUI

struct BuilderMovementCard: View {
    let viewModel: SessionBuilderViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let movement: MovementConfig
    let reorderHandle: ExerciseReorderHandle
    @State private var showingEditor = false
    @State private var showingReplacement = false

    var body: some View {
        WorkoutMovementCard(name: movement.exercise.displayName, sets: movement.sets, reps: movement.reps,
                            restSeconds: movement.restSeconds, reorderHandle: reorderHandle,
                            editIdentifier: "builder.movement.\(movement.id)", dragIdentifier: "builder.drag.\(movement.id)",
                            replaceIdentifier: "builder.replace.\(movement.id)", onEdit: { showingEditor = true },
                            onReplace: { showingReplacement = true })
        .disabled(viewModel.hasInvalidNumbers || viewModel.isSaving)
        .sheet(isPresented: $showingEditor) {
            BuilderMovementEditor(viewModel: viewModel, movementID: movement.id)
                .presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingReplacement) {
            ExercisePickerView(viewModel: ExercisePickerViewModel(exercises: viewModel.allExercises), makeMovement: makeMovement,
                               title: String(localized: .uiWorkoutReplace)) { exercise in
                viewModel.replaceMovement(movement.id, with: exercise)
            }.presentationDetents([.large]).presentationDragIndicator(.hidden)
        }
    }
}
