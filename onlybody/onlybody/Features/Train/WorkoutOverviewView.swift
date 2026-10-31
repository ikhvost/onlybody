import SwiftUI

struct WorkoutOverviewView: View {
    @State var viewModel: WorkoutOverviewViewModel
    let onEdit: () -> Void
    let onStart: () -> Void
    let onExercise: (ExerciseSnapshot) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: String(localized: .uiDesignOverview)) {
                Button { dismiss() } label: { ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize) }
                    .accessibilityLabel(String(localized: .uiBack))
            }
            if viewModel.isLoading {
                ProgressView().tint(Theme.accent).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.text2)
                GhostButton(title: String(localized: .uiRetry)) { Task { await viewModel.load() } }
                Spacer()
            } else if let workout = viewModel.workout {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.sectionGap) {
                        Text(workout.name).font(Theme.fontSans(Theme.typeHeading, .bold)).accessibilityIdentifier("overview.name")
                        Text(workout.scheduledDays.map { CatalogLocalization.label($0) }.joined(separator: " · "))
                            .foregroundStyle(Theme.text2)
                        if !viewModel.summary.focus.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.space8) {
                                Text(.uiDesignFocus).foregroundStyle(Theme.text2)
                                Text(viewModel.summary.focus.map { CatalogLocalization.label($0) }.joined(separator: " · "))
                                    .font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.accent)
                            }
                        }
                        HStack {
                            Text(.uiDesignPlannedSets)
                            Spacer()
                            Text(viewModel.summary.totalSets, format: .number).font(Theme.fontMono(Theme.typeNumber))
                        }
                        if viewModel.items.isEmpty { Text(.uiNoMovementsYet).foregroundStyle(Theme.text2) }
                        ForEach(viewModel.items) { item in
                            WorkoutOverviewExerciseRow(item: item, onExercise: onExercise)
                        }
                        WorkoutMuscleSummaryView(summary: viewModel.summary)
                    }
                    .padding(Theme.horizontalPadding)
                }
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom, spacing: Theme.space0) {
                    HStack(spacing: Theme.space12) {
                        GhostButton(title: String(localized: .uiEditSession), action: onEdit)
                        PrimaryButton(title: String(localized: .uiStartUppercase), action: onStart, disabled: workout.items.isEmpty)
                    }
                    .padding(Theme.cardInset).background(Theme.bg)
                }
            } else {
                Text(.uiWorkoutNotFound).foregroundStyle(Theme.text2)
                Spacer()
            }
        }
        .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text).background(Theme.bg)
        .toolbar(.hidden, for: .navigationBar)
        .background(BackSwipeBridge().allowsHitTesting(false))
        .task { await viewModel.load() }
        .accessibilityIdentifier("overview.screen")
    }
}
