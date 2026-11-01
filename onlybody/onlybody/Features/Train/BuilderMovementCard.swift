import SwiftUI

struct BuilderMovementCard: View {
    let viewModel: SessionBuilderViewModel
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
                        Text(movement.exercise.displayName).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                        Text(String(localized: .uiMovementSummary(movement.sets, movement.reps, movement.restSeconds)))
                            .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    }.frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                }
                .accessibilityIdentifier("builder.movement.\(movement.id)")
            }
            if let index = viewModel.movements.firstIndex(where: { $0.id == movement.id }) {
                ExerciseOrderActions(canMoveUp: index > 0, canMoveDown: index + 1 < viewModel.movements.count,
                                     identifierPrefix: "builder.order.\(movement.id)",
                                     onUp: { viewModel.moveMovement(movement.id, to: viewModel.movements[index - 1].id) },
                                     onDown: { viewModel.moveMovement(movement.id, to: viewModel.movements[index + 1].id) },
                                     onReplace: { showingReplacement = true })
            }
        }
        .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .buttonStyle(PressableButtonStyle(animates: false)).disabled(viewModel.hasInvalidNumbers || viewModel.isSaving)
        .sheet(isPresented: $showingEditor) {
            BuilderMovementEditor(viewModel: viewModel, movementID: movement.id)
                .presentationDetents([.large]).presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingReplacement) {
            ExercisePickerView(viewModel: ExercisePickerViewModel(exercises: viewModel.allExercises),
                               title: String(localized: .uiWorkoutReplace)) { exercise in
                viewModel.replaceMovement(movement.id, with: exercise)
            }.presentationDetents([.large]).presentationDragIndicator(.hidden)
        }
    }
}
