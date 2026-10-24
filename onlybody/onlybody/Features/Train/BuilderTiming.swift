import SwiftUI

struct BuilderTiming: View {
    let viewModel: SessionBuilderViewModel
    @State private var selectedField: WorkoutTimingField?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space10) {
            HStack(spacing: Theme.space12) {
                Button { selectedField = .duration } label: {
                    VStack(alignment: .leading, spacing: Theme.space6) {
                        MonoLabel(text: "Duration", size: Theme.type10, color: Theme.text2)
                        Text("\(viewModel.durationMinutes) min")
                            .font(Theme.fontMono(Theme.type18, .medium))
                            .foregroundStyle(Theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.space14)
                    .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityLabel("Workout duration, \(viewModel.durationMinutes) minutes")
                .accessibilityIdentifier("builder.duration")
                Button { selectedField = .rest } label: {
                    VStack(alignment: .leading, spacing: Theme.space6) {
                        MonoLabel(text: "Set rest", size: Theme.type10, color: Theme.text2)
                        Text(viewModel.hasMixedRest ? "Mixed" : "\(viewModel.restSeconds) sec")
                            .font(Theme.fontMono(Theme.type18, .medium))
                            .foregroundStyle(Theme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.space14)
                    .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityLabel(viewModel.hasMixedRest ? "Set rest, varies by exercise" : "Set rest, \(viewModel.restSeconds) seconds")
                .accessibilityIdentifier("builder.rest")
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            Text(viewModel.mode == .smart
                 ? "Smart selection uses this time budget. Changing set rest applies to all exercises."
                 : "Duration is your target; the estimate below follows your sets. Changing set rest applies to all exercises.")
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space14)
        .sheet(item: $selectedField) { field in
            switch field {
            case .duration:
                WorkoutTimingPicker(title: "Duration", unit: "min", options: WorkoutTimingOptions.durations,
                                    selection: viewModel.durationMinutes, onSelect: viewModel.setDurationMinutes)
            case .rest:
                WorkoutTimingPicker(title: "Set rest", unit: "sec", options: WorkoutTimingOptions.rests,
                                    selection: viewModel.restSeconds, onSelect: viewModel.setDefaultRestSeconds)
            }
        }
    }
}
