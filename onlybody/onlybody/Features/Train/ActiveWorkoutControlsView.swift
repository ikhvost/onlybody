import SwiftUI

struct ActiveWorkoutControlsView: View {
    let viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void
    let onCompleteSet: () -> Void
    let onGuide: () -> Void
    let onHistory: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: Theme.space0) {
                ActiveWorkoutTopBar(currentIndex: viewModel.currentExerciseIndex, totalCount: viewModel.items.count,
                                    elapsedString: time(viewModel.elapsedSeconds), onEnd: onEnd)
                ActiveWorkoutProgressBar(currentIndex: viewModel.currentExerciseIndex, totalCount: viewModel.items.count)
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.sectionGap) {
                        Text(CatalogLocalization.exercise(viewModel.currentExerciseName))
                            .font(Theme.fontSans(Theme.typeExercise, .bold)).foregroundStyle(Theme.text)
                        Text(String(localized: .uiSetProgress(viewModel.currentSetIndex + 1, viewModel.currentSetsTotal)))
                            .font(Theme.fontSans(Theme.typeCard)).foregroundStyle(Theme.accent)
                        Text(viewModel.currentTargetReps > 0
                             ? String(localized: .uiTargetReps(viewModel.currentTargetReps)) : String(localized: .uiMaxHold))
                            .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                        WorkoutNumberInput(title: String(localized: .uiReps), identifier: "Reps",
                                           text: Binding(get: { viewModel.repsText }, set: viewModel.enterReps),
                                           editingID: viewModel.currentKey, hasError: viewModel.invalidNumbers.contains("reps"),
                                           canDecrease: viewModel.currentDisplayReps > 0,
                                           onDecrease: viewModel.decrementReps, onIncrease: viewModel.incrementReps)
                        if viewModel.showsWeight {
                            WorkoutNumberInput(title: String(localized: .uiAddedWeight(viewModel.weightUnitSymbol)),
                                               identifier: "Added \(viewModel.weightUnitSymbol)",
                                               text: Binding(get: { viewModel.weightText }, set: { viewModel.enterWeight($0) }), isDecimal: true,
                                               editingID: viewModel.currentKey,
                                               hasError: viewModel.invalidNumbers.contains("weight"), canDecrease: viewModel.currentWeight > 0,
                                               onDecrease: viewModel.decrementWeight, onIncrease: viewModel.incrementWeight)
                        } else {
                            GhostButton(title: String(localized: .uiDesignAddWeight), action: viewModel.revealWeight)
                                .accessibilityIdentifier("active.addWeight")
                        }
                        ActiveWorkoutExerciseActions(canShowGuide: viewModel.currentItem?.exercise != nil,
                                                     canShowHistory: !viewModel.currentExerciseName.isEmpty,
                                                     onGuide: onGuide, onHistory: onHistory).disabled(viewModel.hasInvalidNumbers)
                        ActiveWorkoutExerciseNavigation(canGoPrevious: viewModel.canGoPrevious, canSkip: viewModel.canSkip,
                                                        onPrevious: viewModel.previousExercise, onSkip: viewModel.skipExercise)
                            .disabled(viewModel.hasInvalidNumbers)
                    }.padding(Theme.horizontalPadding)
                }.scrollIndicators(.hidden)
            }
            .safeAreaInset(edge: .bottom, spacing: Theme.space0) {
                VStack(spacing: Theme.space8) {
                    if viewModel.canSkip {
                        ActiveWorkoutUpNextSection(nextExerciseName: CatalogLocalization.exercise(viewModel.nextExerciseName))
                    }
                    PrimaryButton(title: String(localized: .uiMarkSetDone), action: onCompleteSet,
                                  minimumHeight: Theme.completeHeight, disabled: viewModel.hasInvalidNumbers)
                        .accessibilityIdentifier("active.markSetDone")
                }.padding(Theme.cardInset).background(Theme.bg)
            }
            .accessibilityHidden(viewModel.restTimer.isActive)
            if viewModel.restTimer.isActive {
                RestOverlayView(remainingString: time(viewModel.restTimer.remainingSeconds),
                                nextExerciseName: CatalogLocalization.exercise(viewModel.currentExerciseName),
                                onSkip: viewModel.restTimer.skip,
                                setLabel: String(localized: .uiSetProgress(viewModel.currentSetIndex + 1, viewModel.currentSetsTotal)))
            }
        }
    }

    private func time(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
}
