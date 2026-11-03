import SwiftUI

struct BuilderMovementCard: View {
    let viewModel: SessionBuilderViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let movement: MovementConfig
    let reorderHandle: ExerciseReorderHandle
    @State private var showingEditor = false
    @State private var showingReplacement = false

    var body: some View {
        VStack(spacing: Theme.space8) {
            HStack(spacing: Theme.space8) {
                reorderHandle.accessibilityIdentifier("builder.drag.\(movement.id)")
                Button { showingEditor = true } label: {
                    VStack(alignment: .leading, spacing: Theme.space8) {
                        Text(movement.exercise.displayName).font(Theme.fontSans(Theme.typeBody, .semibold)).foregroundStyle(Theme.text)
                        Text(String(localized: .uiMovementSummary(movement.sets, movement.reps, movement.restSeconds)))
                            .font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    }.frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                }
                .accessibilityIdentifier("builder.movement.\(movement.id)")
                ExerciseReplaceButton(identifier: "builder.replace.\(movement.id)") {
                    showingReplacement = true
                }
            }
        }
        .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .buttonStyle(PressableButtonStyle(animates: false)).disabled(viewModel.hasInvalidNumbers || viewModel.isSaving)
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
