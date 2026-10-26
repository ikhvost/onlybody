import SwiftUI

struct ActiveWorkoutView: View {
    @State var viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void
    let onGuide: (ExerciseSnapshot) -> Void
    let onHistory: (String) -> Void

    @State private var showEndPrompt = false
    @State private var setCompletedCount = 0
    @State private var navigationCount = 0

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
                    exerciseCount: viewModel.items.count,
                    saveState: viewModel.saveState,
                    onRetry: { Task { await viewModel.retrySave() } },
                    errorMessage: viewModel.errorMessage,
                    onEnd: onEnd
                )
            } else if !viewModel.items.isEmpty {
                ActiveWorkoutBody(
                    currentIndex: viewModel.currentExerciseIndex,
                    totalCount: viewModel.items.count,
                    elapsedString: formatTime(viewModel.elapsedSeconds),
                    exerciseName: CatalogLocalization.exercise(viewModel.currentExerciseName),
                    setLabel: String(localized: .uiSetProgress(viewModel.currentSetIndex + 1, viewModel.currentSetsTotal))
                        + " · " + (viewModel.currentTargetReps > 0
                            ? String(localized: .uiTargetReps(viewModel.currentTargetReps)) : String(localized: .uiMaxHold)),
                    totalSets: viewModel.currentSetsTotal,
                    completedSets: viewModel.completedSetsForCurrent,
                    currentSetIndex: viewModel.currentSetIndex,
                    reps: viewModel.currentDisplayReps,
                    weight: viewModel.displayedWeight,
                    weightUnit: viewModel.weightUnitSymbol,
                    errorMessage: viewModel.errorMessage,
                    canGoPrevious: viewModel.canGoPrevious,
                    canSkip: viewModel.canSkip,
                    nextExerciseName: CatalogLocalization.exercise(viewModel.nextExerciseName),
                    isRestActive: viewModel.restTimer.isActive,
                    restSecondsString: formatTime(viewModel.restTimer.remainingSeconds),
                    restNextName: CatalogLocalization.exercise(viewModel.restTimer.nextExerciseName),
                    onEnd: { showEndPrompt = true },
                    onMarkSetDone: { viewModel.markSetDone(); setCompletedCount += 1 },
                    onIncrementReps: { viewModel.incrementReps() },
                    onDecrementReps: { viewModel.decrementReps() },
                    onIncrementWeight: { viewModel.incrementWeight() },
                    onDecrementWeight: { viewModel.decrementWeight() },
                    onPreviousExercise: { viewModel.previousExercise(); navigationCount += 1 },
                    onSkipExercise: { viewModel.skipExercise(); navigationCount += 1 },
                    onSkipRest: { viewModel.restTimer.skip() },
                    canShowGuide: viewModel.currentItem?.exercise != nil,
                    onGuide: {
                        if let exercise = viewModel.currentItem?.exercise { onGuide(exercise) }
                    },
                    onHistory: { onHistory(viewModel.currentExerciseName) }
                )
            }
        }
        .alert(String(localized: .uiEndWorkout), isPresented: $showEndPrompt) {
            Button(String(localized: .uiEndSave)) {
                Task {
                    await viewModel.endSession()
                    if viewModel.errorMessage == nil {
                        onEnd()
                    }
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
        .sensoryFeedback(.impact(weight: .medium), trigger: setCompletedCount)
        .sensoryFeedback(.selection, trigger: navigationCount)
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
