import SwiftUI

struct BuilderTiming: View {
    let viewModel: SessionBuilderViewModel
    @State private var selectedField: WorkoutTimingField?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space10) {
            HStack(spacing: Theme.space12) {
                Button { selectedField = .duration } label: {
                    VStack(alignment: .leading, spacing: Theme.space6) {
                        MonoLabel(text: String(localized: .uiDuration), size: Theme.type10, color: Theme.text2)
                        Text(String(localized: .uiMinutesCount(viewModel.durationMinutes)))
                            .font(Theme.fontMono(Theme.type18, .medium))
                            .foregroundStyle(Theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.space14)
                    .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityLabel(String(localized: .uiWorkoutDuration(viewModel.durationMinutes)))
                .accessibilityIdentifier("builder.duration")
                Button { selectedField = .rest } label: {
                    VStack(alignment: .leading, spacing: Theme.space6) {
                        MonoLabel(text: String(localized: .uiSetRest), size: Theme.type10, color: Theme.text2)
                        Text(viewModel.hasMixedRest ? String(localized: .uiMixed) : String(localized: .uiSecondsCount(viewModel.restSeconds)))
                            .font(Theme.fontMono(Theme.type18, .medium))
                            .foregroundStyle(Theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.space14)
                    .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityLabel(viewModel.hasMixedRest
                    ? String(localized: .uiSetRestVariesByExercise)
                    : String(localized: .uiSetRestSeconds(viewModel.restSeconds)))
                .accessibilityIdentifier("builder.rest")
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            Text(viewModel.mode == .smart
                 ? String(localized: .uiSmartSelectionUsesThisTimeBudgetChangingSetRestApplies)
                 : String(localized: .uiDurationIsYourTargetTheEstimateBelowFollowsYourSets))
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space14)
        .sheet(item: $selectedField) { field in
            switch field {
            case .duration:
                WorkoutTimingPicker(title: String(localized: .uiDuration), unit: String(localized: .uiMin), options: WorkoutTimingOptions.durations,
                                    selection: viewModel.durationMinutes, onSelect: viewModel.setDurationMinutes)
            case .rest:
                WorkoutTimingPicker(title: String(localized: .uiSetRest), unit: String(localized: .uiSec), options: WorkoutTimingOptions.rests,
                                    selection: viewModel.restSeconds, onSelect: viewModel.setDefaultRestSeconds)
            }
        }
    }
}
