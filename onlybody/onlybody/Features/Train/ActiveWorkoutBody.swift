import SwiftUI

struct ActiveWorkoutBody: View {
    let currentIndex: Int
    let totalCount: Int
    let elapsedString: String
    let exerciseName: String
    let setLabel: String
    let totalSets: Int
    let completedSets: Int
    let currentSetIndex: Int
    let reps: Int
    let weight: Double
    let errorMessage: String?
    let canGoPrevious: Bool
    let canSkip: Bool
    let nextExerciseName: String
    let isRestActive: Bool
    let restSecondsString: String
    let restNextName: String
    let onEnd: () -> Void
    let onMarkSetDone: () -> Void
    let onIncrementReps: () -> Void
    let onDecrementReps: () -> Void
    let onIncrementWeight: () -> Void
    let onDecrementWeight: () -> Void
    let onPreviousExercise: () -> Void
    let onSkipExercise: () -> Void
    let onSkipRest: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: Theme.space0) {
                ActiveWorkoutTopBar(
                    currentIndex: currentIndex,
                    totalCount: totalCount,
                    elapsedString: elapsedString,
                    onEnd: onEnd
                )

                ActiveWorkoutProgressBar(
                    currentIndex: currentIndex,
                    totalCount: totalCount
                )

                if let error = errorMessage {
                    MonoLabel(
                        text: error,
                        size: Theme.type10,
                        color: Theme.danger,
                        tracking: 0.4
                    )
                    .padding(.top, Theme.space4)
                }

                ActiveWorkoutExerciseContent(
                    exerciseName: exerciseName,
                    setLabel: setLabel,
                    totalSets: totalSets,
                    completedSets: completedSets,
                    currentSetIndex: currentSetIndex,
                    reps: reps,
                    weight: weight,
                    canGoPrevious: canGoPrevious,
                    canSkip: canSkip,
                    nextExerciseName: nextExerciseName,
                    onMarkSetDone: onMarkSetDone,
                    onIncrementReps: onIncrementReps,
                    onDecrementReps: onDecrementReps,
                    onIncrementWeight: onIncrementWeight,
                    onDecrementWeight: onDecrementWeight,
                    onPreviousExercise: onPreviousExercise,
                    onSkipExercise: onSkipExercise
                )
            }

            if isRestActive {
                RestOverlayView(
                    remainingString: restSecondsString,
                    nextExerciseName: restNextName,
                    onSkip: onSkipRest
                )
            }
        }
    }
}
