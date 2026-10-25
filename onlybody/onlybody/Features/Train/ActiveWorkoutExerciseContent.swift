import SwiftUI

struct ActiveWorkoutExerciseContent: View {
    let exerciseName: String
    let setLabel: String
    let totalSets: Int
    let completedSets: Int
    let currentSetIndex: Int
    let reps: Int
    let weight: Double
    let weightUnit: String
    let canGoPrevious: Bool
    let canSkip: Bool
    let nextExerciseName: String
    let onMarkSetDone: () -> Void
    let onIncrementReps: () -> Void
    let onDecrementReps: () -> Void
    let onIncrementWeight: () -> Void
    let onDecrementWeight: () -> Void
    let onPreviousExercise: () -> Void
    let onSkipExercise: () -> Void

    let canShowGuide: Bool
    let onGuide: () -> Void
    let onHistory: () -> Void

    var body: some View {
        VStack(spacing: Theme.space0) {
            ScrollView {
                VStack(spacing: Theme.space0) {
                    ActiveWorkoutExerciseHeader(
                        exerciseName: exerciseName,
                        setLabel: setLabel
                    )
                    .padding(.horizontal, Theme.horizontalPadding)

                    ActiveWorkoutExerciseActions(
                        canShowGuide: canShowGuide,
                        canShowHistory: !exerciseName.isEmpty,
                        onGuide: onGuide,
                        onHistory: onHistory
                    )
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, Theme.space16)

                    SetTrackerView(
                        total: totalSets,
                        completed: completedSets,
                        current: currentSetIndex
                    )
                    .padding(.top, Theme.space28)
                    .padding(.horizontal, Theme.horizontalPadding)

                    ActiveWorkoutStepperCards(
                        reps: reps,
                        weight: weight,
                        weightUnit: weightUnit,
                        onIncrementReps: onIncrementReps,
                        onDecrementReps: onDecrementReps,
                        onIncrementWeight: onIncrementWeight,
                        onDecrementWeight: onDecrementWeight
                    )
                    .padding(.top, Theme.space16)
                    .padding(.horizontal, Theme.horizontalPadding)

                    ActiveWorkoutExerciseNavigation(
                        canGoPrevious: canGoPrevious,
                        canSkip: canSkip,
                        onPrevious: onPreviousExercise,
                        onSkip: onSkipExercise
                    )
                    .padding(.top, Theme.space14)
                    .padding(.horizontal, Theme.horizontalPadding)
                }
                .padding(.top, Theme.space20)
            }
            .scrollIndicators(.hidden)

            if canSkip {
                ActiveWorkoutUpNextSection(nextExerciseName: nextExerciseName)
            }

            PrimaryButton(title: "Mark Set Done") {
                onMarkSetDone()
            }
            .accessibilityIdentifier("active.markSetDone")
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.bottom, Theme.space18)
            .padding(.top, Theme.space8)
        }
    }
}
