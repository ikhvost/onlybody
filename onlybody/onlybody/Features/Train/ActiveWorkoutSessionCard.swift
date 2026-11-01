import SwiftUI

struct ActiveWorkoutSessionCard: View {
    let viewModel: ActiveWorkoutViewModel
    let item: WorkoutItemSnapshot
    let index: Int
    let onReplace: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            HStack(spacing: Theme.space8) {
                ReorderIcon().frame(width: Theme.touchSize, height: Theme.touchSize)
                    .contentShape(.rect).draggable(item.id.uuidString)
                    .accessibilityLabel(String(localized: .uiWorkoutReorder))
                Button { viewModel.showExercise(item.id) } label: {
                    VStack(alignment: .leading, spacing: Theme.space6) {
                        Text(viewModel.completedCount(for: item.id) == item.sets ? .uiWorkoutCompleted
                             : viewModel.currentItemID == item.id ? .uiWorkoutCurrent : .uiWorkoutUpcoming)
                            .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                        Text(CatalogLocalization.exercise(item.exercise?.name ?? ""))
                            .font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                        Text(String(localized: .uiSetProgress(viewModel.completedCount(for: item.id), item.sets)))
                            .font(Theme.fontMono(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    }.frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                }
                .buttonStyle(PressableButtonStyle(animates: false))
                .accessibilityIdentifier("active.exercise.\(index)")
            }
            ExerciseOrderActions(canMoveUp: index > 0, canMoveDown: index + 1 < viewModel.items.count,
                                 canReplace: viewModel.canReplace(item.id), identifierPrefix: "active.exercise.\(index)",
                                 onUp: { viewModel.moveExercise(item.id, to: viewModel.items[index - 1].id) },
                                 onDown: { viewModel.moveExercise(item.id, to: viewModel.items[index + 1].id) }, onReplace: onReplace)
            if !viewModel.canReplace(item.id) {
                Text(.uiWorkoutReplaceLocked).font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text3)
            }
        }
        .padding(Theme.cardInset)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(viewModel.currentItemID == item.id ? Theme.accent : Theme.border)
        }
        .dropDestination(for: String.self) { values, _ in
            if let value = values.first, let id = UUID(uuidString: value) { viewModel.moveExercise(id, to: item.id) }
        }
        .disabled(viewModel.hasInvalidNumbers)
    }
}
