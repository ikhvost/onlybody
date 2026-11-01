import SwiftUI

struct ActiveWorkoutView: View {
    @State var viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void
    let onGuide: (ExerciseSnapshot) -> Void
    let onHistory: (String) -> Void

    @State private var showEndPrompt = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if viewModel.isLoading {
                ActiveWorkoutLoadingView()
            } else if viewModel.errorMessage != nil && viewModel.items.isEmpty {
                ActiveWorkoutErrorView(
                    errorMessage: viewModel.errorMessage,
                    onEnd: onEnd
                )
            } else if viewModel.isComplete {
                ActiveWorkoutCompletionView(
                    elapsedString: formatTime(viewModel.elapsedSeconds),
                    completedSets: viewModel.completedSetCount,
                    saveState: viewModel.saveState,
                    onRetry: { Task { await viewModel.retrySave() } },
                    errorMessage: viewModel.errorMessage,
                    onEnd: onEnd
                )
            } else if !viewModel.items.isEmpty {
                if viewModel.showsExerciseList {
                    ActiveWorkoutSessionList(viewModel: viewModel, onClose: onEnd, onEnd: { showEndPrompt = true })
                } else {
                    ActiveWorkoutContentView(
                        viewModel: viewModel,
                        onGuide: { if let exercise = viewModel.currentItem?.exercise { onGuide(exercise) } },
                        onHistory: { onHistory(viewModel.currentExerciseName) }
                    )
                }
            }
        }
        .alert(String(localized: .uiEndWorkout), isPresented: $showEndPrompt) {
            Button(String(localized: .uiEndSave)) {
                Task {
                    await viewModel.endSession()
                    // Keep the result screen visible for success, failure, and empty completion.
                }
            }
            Button(String(localized: .uiEndWithoutSaving), role: .destructive) {
                if viewModel.discardSession() { onEnd() }
            }
            Button(String(localized: .uiContinue), role: .cancel) {}
        } message: {
            Text(.uiSaveYourCompletedSetsOrEndWithoutAddingThisWorkout)
        }
        .task {
            await viewModel.load()
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.completedSetCount)
        .sensoryFeedback(.selection, trigger: viewModel.viewedItemID)
    }

    private func formatTime(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
}

#if DEBUG
#Preview("Active Workout") {
    let exercise = ExerciseSnapshot(name: "Push-Ups", primaryMuscle: "Chest")
    let workout = WorkoutSnapshot(
        name: "Full Body",
        items: [WorkoutItemSnapshot(exercise: exercise)]
    )
    return ActiveWorkoutView(
        viewModel: ActiveWorkoutViewModel(
            workouts: PreviewWorkoutRepository(workouts: [workout]),
            sessions: PreviewSessionRepository(),
            workoutId: workout.id
        ),
        onEnd: {},
        onGuide: { _ in },
        onHistory: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif
