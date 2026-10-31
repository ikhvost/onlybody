import SwiftUI

struct TrainView: View {
    let viewModel: TrainViewModel
    let showSettings: () -> Void
    let showMusclePicker: () -> Void
    let showSessionBuilder: (UUID?) -> Void
    let onStartWorkout: (UUID) -> Void

    var onOverview: (UUID) -> Void = { _ in }

    private var contentState: String {
        if viewModel.isLoading { return "loading" }
        if viewModel.errorMessage != nil { return "error" }
        if viewModel.workouts.isEmpty { return "empty" }
        return "content"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                TrainHeader(
                    appName: viewModel.appName,
                    dateDisplay: viewModel.dateDisplay,
                    onSettingsTap: showSettings,
                    onCreateTap: {
                        showMusclePicker()
                    }
                )

                ZStack {
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .tint(Theme.accent)
                            Spacer()
                        }
                        .transition(.opacity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            VStack(spacing: Theme.space10) {
                                MonoLabel(text: errorMessage, size: Theme.typeMeta, color: Theme.text2, tracking: 0.4)
                                Button(String(localized: .uiRetry)) {
                                    Task { await viewModel.load() }
                                }
                                .font(Theme.fontMono(Theme.typeMeta, .medium))
                                .foregroundStyle(Theme.accent)
                                .buttonStyle(PressableButtonStyle())
                            }
                            Spacer()
                        }
                        .transition(.opacity)
                    } else if viewModel.workouts.isEmpty {
                        VStack {
                            Spacer()
                            TrainEmptyState(onCreate: showMusclePicker)
                            Spacer()
                        }
                        .transition(.opacity)
                    } else {
                        VStack(spacing: Theme.space0) {
                            WorkoutList(
                                workouts: viewModel.workouts,
                                todayName: viewModel.todayName,
                                onEdit: { workout in
                                    showSessionBuilder(workout.id)
                                },
                                onStart: { workout in
                                    onStartWorkout(workout.id)
                                },
                                onOverview: { onOverview($0.id) }
                            )
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: contentState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
    }
}

#if DEBUG
#Preview("Train — placeholder") {
    TrainView(
        viewModel: TrainViewModel(
            workouts: PreviewWorkoutRepository(), appName: AppConfiguration.current.displayName
        ),
        showSettings: {},
        showMusclePicker: {},
        showSessionBuilder: { _ in },
        onStartWorkout: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif

#if DEBUG
#Preview("Train — workouts") {
    let exercise = ExerciseSnapshot(name: "Push-Ups", primaryMuscle: "Chest")
    let workout = WorkoutSnapshot(
        name: "Full Body",
        items: [WorkoutItemSnapshot(exercise: exercise)]
    )
    return TrainView(
        viewModel: TrainViewModel(
            workouts: PreviewWorkoutRepository(workouts: [workout]), appName: AppConfiguration.current.displayName
        ),
        showSettings: {},
        showMusclePicker: {},
        showSessionBuilder: { _ in },
        onStartWorkout: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif
