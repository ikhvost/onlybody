import SwiftUI

struct SmartDailyPreviewView: View {
    let viewModel: SmartSelectionViewModel
    let onReplace: (WorkoutItemSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            Text(viewModel.dayLabel).foregroundStyle(Theme.text2)
            Text(.smartToday).font(Theme.fontSans(Theme.typeHeading, .bold))
            HStack {
                Text(viewModel.configuration.level.label)
                Spacer()
                Text(.smartEstimate)
                Text(viewModel.estimatedMinutes, format: .number)
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
            ForEach(viewModel.variant?.items ?? []) { item in
                SmartMovementCard(item: item, onReplace: { onReplace(item) })
            }
        }
    }
}
