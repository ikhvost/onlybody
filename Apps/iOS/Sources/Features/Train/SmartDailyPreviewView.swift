import SwiftUI

struct SmartDailyPreviewView: View {
    let viewModel: SmartSelectionViewModel
    @Binding var dragLocation: CGPoint?
    let onEdit: (WorkoutItemSnapshot) -> Void
    let onReplace: (WorkoutItemSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            WorkoutOverviewHeader(name: viewModel.displayName,
                subtitle: viewModel.dayLabel + " · " + viewModel.configuration.level.label + " · "
                    + String(localized: .uiMinutesCount(viewModel.estimatedMinutes)),
                focus: viewModel.configuration.targetMuscleGroups, nameIdentifier: "smart.preview.name", isSmart: true)
            if !viewModel.gaps.isEmpty {
                VStack(alignment: .leading, spacing: Theme.space12) {
                    Text(.smartGap).font(Theme.fontSans(Theme.typeCard, .semibold))
                    Text(viewModel.gaps.joined(separator: " · "))
                    Text(.smartGapHint).font(Theme.fontSans(Theme.typeMeta))
                    GhostButton(title: String(localized: .smartChange)) { viewModel.edit() }
                }.padding(Theme.cardInset).background(Theme.accentDim, in: .rect(cornerRadius: Theme.cornerRadius))
            }
            if viewModel.assessment.status == .shorter {
                Text(.smartShortPlanHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
            MonoLabel(text: String(localized: .uiMovements), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)
            ExerciseReorderStack(items: viewModel.variant?.items ?? [], spacing: Theme.space6,
                                 isEnabled: !viewModel.isBusy, dragLocation: $dragLocation,
                                 onMove: move) { item, handle in
                SmartMovementCard(item: item, reorderHandle: handle, onEdit: { onEdit(item) }, onReplace: { onReplace(item) })
            }
            Text(.smartDailyHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
        }
    }

    private func move(_ source: UUID, _ target: UUID) {
        Task { await viewModel.moveMovement(source, to: target) }
    }
}
