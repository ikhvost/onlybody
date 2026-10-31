import SwiftUI

struct ActiveWorkoutControlsView: View {
    let viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void
    let onCompleteSet: () -> Void
    let onGuide: () -> Void
    let onHistory: () -> Void

    var body: some View {
        if viewModel.restTimer.isActive {
            RestOverlayView(
                remainingString: Duration.seconds(viewModel.restTimer.remainingSeconds)
                    .formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2))),
                nextExerciseName: CatalogLocalization.exercise(viewModel.currentExerciseName),
                onSkip: viewModel.restTimer.skip,
                setLabel: String(localized: .uiSetProgress(viewModel.currentSetIndex + 1, viewModel.currentSetsTotal))
            )
        } else {
            ActiveWorkoutContentView(viewModel: viewModel, onEnd: onEnd, onCompleteSet: onCompleteSet,
                                     onGuide: onGuide, onHistory: onHistory)
        }
    }
}
