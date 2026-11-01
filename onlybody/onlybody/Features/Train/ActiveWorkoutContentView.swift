import SwiftUI

struct ActiveWorkoutContentView: View {
    let viewModel: ActiveWorkoutViewModel
    let onGuide: () -> Void
    let onHistory: () -> Void

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView {
                Button { viewModel.showList() } label: {
                    ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize)
                }
                .accessibilityLabel(String(localized: .uiBackToWorkout))
                .accessibilityIdentifier("active.list").disabled(viewModel.hasInvalidNumbers)
            } trailing: {
                Text(Duration.seconds(viewModel.elapsedSeconds), format: .time(pattern: .minuteSecond(padMinuteToLength: 2)))
                    .font(Theme.fontMono(Theme.typeMeta))
            }
            CompactRestTimerView(viewModel: viewModel)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Theme.space12) {
                    Text(viewModel.hasStarted ? (viewModel.completedSetsForCurrent == viewModel.currentSetsTotal ? .uiWorkoutCompleted
                         : viewModel.currentItemID == viewModel.viewedItemID
                         ? .uiWorkoutCurrent : .uiWorkoutUpcoming) : .uiWorkoutPreview)
                        .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    Text(CatalogLocalization.exercise(viewModel.currentExerciseName))
                        .font(Theme.fontSans(Theme.typeExercise, .bold))
                    Text(viewModel.currentTargetReps > 0 ? String(localized: .uiTargetReps(viewModel.currentTargetReps))
                         : String(localized: .uiMaxHold))
                        .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    ActiveWorkoutExerciseActions(canShowGuide: viewModel.currentItem?.exercise != nil,
                                                 canShowHistory: !viewModel.currentExerciseName.isEmpty,
                                                 onGuide: onGuide, onHistory: onHistory).disabled(viewModel.hasInvalidNumbers)
                    if !viewModel.showsWeight {
                        GhostButton(title: String(localized: .uiDesignAddWeight), action: viewModel.revealWeight)
                            .accessibilityIdentifier("active.addWeight")
                    }
                    HStack(spacing: Theme.space10) {
                        Text(.uiWorkoutSet).frame(width: Theme.touchSize)
                        Text(.uiReps).frame(maxWidth: .infinity)
                        if viewModel.showsWeight { Text(viewModel.weightUnitSymbol).frame(maxWidth: .infinity) }
                        CheckIcon().frame(width: Theme.stepSize)
                    }.font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    if let item = viewModel.currentItem {
                        ForEach(0..<max(0, item.sets), id: \.self) { index in
                            ActiveWorkoutSetRow(viewModel: viewModel, setID: WorkoutSetID(itemID: item.id, index: index))
                        }
                    }
                    if viewModel.hasInvalidNumbers {
                        Text(.uiDesignNumberError).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
                    }
                }.padding(Theme.horizontalPadding)
            }.scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
        }
        .id(viewModel.viewedItemID)
    }
}
