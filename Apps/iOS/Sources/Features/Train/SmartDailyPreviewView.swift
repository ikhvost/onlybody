import SwiftUI

struct SmartDailyPreviewView: View {
    let viewModel: SmartSelectionViewModel
    @Binding var dragLocation: CGPoint?
    let onReplace: (WorkoutItemSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            Text(viewModel.dayLabel).foregroundStyle(Theme.text2)
            Text(.smartToday).font(Theme.fontSans(Theme.typeHeading, .bold))
            HStack {
                Text(viewModel.configuration.level.label)
                Spacer()
                Text(.smartEstimate)
                Text(.uiMinutesCount(viewModel.estimatedMinutes))
            }.font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.accent)
            HStack {
                Text(.smartBudget)
                Text(.uiMinutesCount(viewModel.configuration.durationMinutes))
            }.font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            Text(.smartDailyHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
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
            ExerciseReorderStack(items: viewModel.variant?.items ?? [], spacing: Theme.space6,
                                 isEnabled: !viewModel.isBusy, dragLocation: $dragLocation,
                                 onMove: move) { item, handle in
                SmartMovementCard(item: item, reorderHandle: handle, onReplace: { onReplace(item) })
            }
        }
    }

    private func move(_ source: UUID, _ target: UUID) {
        Task { await viewModel.moveMovement(source, to: target) }
    }
}
