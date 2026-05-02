import SwiftUI

struct TrainView: View {
    let viewModel: TrainViewModel
    let showMusclePicker: () -> Void
    let showSessionBuilder: (UUID?) -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                TrainHeaderView(
                    dateDisplay: viewModel.dateDisplay,
                    onCreateTap: {
                        showMusclePicker()
                    }
                )

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(Theme.accent)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: Theme.space10) {
                        MonoLabel(text: errorMessage, size: 10, color: Theme.text2, tracking: 0.4)
                        Button("Retry") {
                            Task { await viewModel.load() }
                        }
                        .font(Theme.fontMono(12, .medium))
                        .foregroundStyle(Theme.accent)
                    }
                    Spacer()
                } else if viewModel.workouts.isEmpty {
                    Spacer()
                    TrainEmptyStateView()
                    Spacer()
                } else {
                    DayStripView(
                        dayNames: viewModel.dayNames,
                        todayIndex: viewModel.todayIndex,
                        workouts: viewModel.workouts
                    )
                    TodayCalloutView(
                        todaysWorkouts: viewModel.todaysWorkouts
                    )
                    WorkoutListView(
                        workouts: viewModel.workouts,
                        todayName: viewModel.todayName,
                        onEdit: { workout in
                            showSessionBuilder(workout.id)
                        },
                        onStart: { _ in
                            // Future: open ActiveSession
                        }
                    )
                }
            }
        }
        .task { await viewModel.load() }
    }
}

#Preview("Train — placeholder") {
    TrainView(
        viewModel: TrainViewModel(
            workouts: PlaceholderWorkoutRepository(),
            sessions: PlaceholderSessionRepository()
        ),
        showMusclePicker: {},
        showSessionBuilder: { _ in }
    )
    .preferredColorScheme(.dark)
}

private struct PlaceholderWorkoutRepository: WorkoutRepository {
    func allWorkouts() async throws -> [Workout] { [] }
    func save(_ workout: Workout) async throws {}
    func delete(_ workout: Workout) async throws {}
    func deleteItems(_ items: [WorkoutItem]) async throws {}
}

private struct PlaceholderSessionRepository: SessionRepository {
    func allSessions() async throws -> [Session] { [] }
    func recentSessions(limit: Int) async throws -> [Session] { [] }
    func save(_ session: Session) async throws {}
}
