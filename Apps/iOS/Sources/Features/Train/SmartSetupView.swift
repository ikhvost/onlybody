import SwiftUI

struct SmartSetupView: View {
    @Bindable var viewModel: SmartSelectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            Text(.smartSetup).font(Theme.fontSans(Theme.typeHeading, .bold))
            Text(.smartDuration).font(Theme.fontSans(Theme.typeCard, .semibold))
            FlowLayout(spacing: Theme.space8) {
                ForEach([15, 30, 45, 60], id: \.self) { minutes in
                    ChipView(label: String(localized: .uiMinutesCount(minutes)), isActive: viewModel.configuration.durationMinutes == minutes) {
                        viewModel.configuration.durationMinutes = minutes
                    }.accessibilityIdentifier("smart.duration.\(minutes)")
                }
            }
            Text(.smartTimeHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            Text(.smartLevel).font(Theme.fontSans(Theme.typeCard, .semibold))
            FlowLayout(spacing: Theme.space8) {
                ForEach(ExerciseDifficulty.ratedLevels, id: \.self) { level in
                    ChipView(label: level.label, isActive: viewModel.configuration.level == level) { viewModel.configuration.level = level }
                }
            }
            Text(.smartLevelHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            Text(.uiTargets).font(Theme.fontSans(Theme.typeCard, .semibold))
            FlowLayout(spacing: Theme.space8) {
                ForEach(viewModel.targets, id: \.self) { target in
                    ChipView(label: CatalogLocalization.label(target), isActive: viewModel.configuration.targetMuscleGroups.contains(target)) {
                        viewModel.toggleTarget(target)
                    }.disabled(!viewModel.canToggleTarget(target))
                        .accessibilityIdentifier("smart.target.\(target)")
                }
            }
            Text(.smartTargetRule).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            if !viewModel.configuration.targetMuscleGroups.isEmpty, !viewModel.hasValidTargets {
                Text(.smartInvalidTargets).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
            }
            Text(.smartSchedule).font(Theme.fontSans(Theme.typeCard, .semibold)).accessibilityIdentifier("smart.name.label")
            WorkoutNameField(name: $viewModel.name, identifier: "smart.name")
            FlowLayout(spacing: Theme.space8) {
                ForEach(Weekdays.shortNames, id: \.self) { day in
                    ChipView(label: CatalogLocalization.label(day), isActive: viewModel.scheduledDays.contains(day)) { viewModel.toggleDay(day) }
                }
            }
        }
    }
}
