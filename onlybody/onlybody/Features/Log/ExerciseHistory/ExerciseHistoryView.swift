import SwiftUI

struct ExerciseHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ExerciseHistoryViewModel

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.space0) {
                NavBarView(title: "History") {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: Theme.space4) {
                            ChevronIcon(isBack: true, color: Theme.accent, size: Theme.type16, inset: 8)
                            Text("Back")
                                .font(Theme.fontSans(Theme.type15, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                        .frame(minHeight: Theme.space44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to workout")
                    .accessibilityIdentifier("exerciseHistory.back")
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space20) {
                        Text(viewModel.exerciseName)
                            .font(Theme.fontSans(Theme.type28, .heavy))
                            .foregroundStyle(Theme.text)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("exerciseHistory.name")

                        if viewModel.isLoading {
                            ProgressView("Loading history…")
                                .tint(Theme.accent)
                                .foregroundStyle(Theme.text2)
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .font(Theme.fontSans(Theme.type14))
                                .foregroundStyle(Theme.text2)
                            GhostButton(title: "Retry") { Task { await viewModel.load() } }
                                .accessibilityIdentifier("exerciseHistory.retry")
                        } else if viewModel.entries.isEmpty {
                            Text("No completed sets yet")
                                .font(Theme.fontSans(Theme.type18, .semibold))
                                .foregroundStyle(Theme.text)
                                .accessibilityIdentifier("exerciseHistory.empty")
                            Text("After you save a workout with this exercise, its date, reps and added weight will appear here.")
                                .font(Theme.fontSans(Theme.type14))
                                .foregroundStyle(Theme.text2)
                        } else {
                            ExerciseHistorySummary(
                                workouts: viewModel.entries.count,
                                sets: viewModel.totalSets,
                                reps: viewModel.totalReps
                            )
                            LazyVStack(spacing: Theme.space14) {
                                ForEach(viewModel.entries) { entry in
                                    ExerciseHistoryRow(entry: entry)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.vertical, Theme.space20)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }
}

#if DEBUG
#Preview("Exercise history") {
    let item = SessionItemSnapshot(exerciseName: "Standard Push-Ups", setReps: [12, 10, 8], weightKg: 5)
    let session = SessionSnapshot(date: Date(timeIntervalSince1970: 1_790_000_000), workoutName: "Upper Body", items: [item])
    ExerciseHistoryView(viewModel: ExerciseHistoryViewModel(
        exerciseName: item.exerciseName, sessions: PreviewSessionRepository(sessions: [session])
    ))
    .preferredColorScheme(.dark)
}

#Preview("Empty exercise history") {
    ExerciseHistoryView(viewModel: ExerciseHistoryViewModel(
        exerciseName: "Standard Push-Ups", sessions: PreviewSessionRepository()
    ))
    .preferredColorScheme(.dark)
}
#endif
