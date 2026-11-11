import SwiftUI

struct ActiveWorkoutContentView: View {
    let viewModel: ActiveWorkoutViewModel
    let onGuide: () -> Void
    let onHistory: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focusedField: WorkoutSetField?
    @State private var scrollPosition = ScrollPosition(idType: String.self)
    @State private var editedItemID: UUID?

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView {
                Button { dismissKeyboard(); viewModel.showList() } label: {
                    ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize)
                }
                .accessibilityLabel(String(localized: .uiBackToWorkout))
                .accessibilityIdentifier("active.list").disabled(viewModel.hasInvalidNumbers)
            } trailing: {
                Text(Duration.seconds(viewModel.elapsedSeconds), format: .time(pattern: .minuteSecond(padMinuteToLength: 2)))
                    .font(Theme.fontMono(Theme.typeMeta)).accessibilityIdentifier("active.elapsed")
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
                    if viewModel.smartConfiguration != nil, let rule = viewModel.currentItem?.exercise?.smartMetadata?.repetitionRule, rule != .total {
                        Text(rule.label).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.accent)
                    }
                    ActiveWorkoutExerciseActions(canShowGuide: viewModel.currentItem?.exercise != nil,
                                                 canShowHistory: !viewModel.currentExerciseName.isEmpty,
                                                 onGuide: { dismissKeyboard(); onGuide() },
                                                 onHistory: { dismissKeyboard(); onHistory() }).disabled(viewModel.hasInvalidNumbers)
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
                            ActiveWorkoutSetRow(viewModel: viewModel, setID: WorkoutSetID(itemID: item.id, index: index),
                                                focusedField: $focusedField, onDismissKeyboard: dismissKeyboard)
                        }
                    }
                    if viewModel.hasStarted {
                        ActiveWorkoutSetActions(viewModel: viewModel) {
                            updateSets { _ = viewModel.addSet() }
                        } onRemove: {
                            updateSets { viewModel.removeLastSet() }
                        }
                        .id("active.set.actions")
                    }
                    if viewModel.hasInvalidNumbers {
                        Text(.uiDesignNumberError).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
                    }
                }
                .scrollTargetLayout()
                .padding(Theme.horizontalPadding)
            }
            .scrollPosition($scrollPosition)
            .scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height + geometry.contentInsets.top + geometry.contentInsets.bottom - geometry.containerSize.height
            } action: { _, overflow in
                guard editedItemID == viewModel.viewedItemID, editedItemID != nil else { return }
                editedItemID = nil
                withAnimation(reduceMotion ? nil : Theme.setEditingAnimation) {
                    if overflow > 0 {
                        scrollPosition.scrollTo(id: "active.set.actions", anchor: .bottom)
                    } else {
                        scrollPosition.scrollTo(edge: .top)
                    }
                }
            }
        }
        .background(KeyboardOutsideTapBridge(isEnabled: focusedField != nil, onDismiss: dismissKeyboard).allowsHitTesting(false))
        .background(BackActionSwipeBridge(isEnabled: !viewModel.hasInvalidNumbers, onBack: viewModel.showList).allowsHitTesting(false))
        .onChange(of: focusedField) { old, new in
            if let old { viewModel.endNumberEditing(old) }
            if let new { viewModel.beginNumberEditing(new) }
        }
        .onDisappear(perform: dismissKeyboard)
        .id(viewModel.viewedItemID)
        .onChange(of: viewModel.viewedItemID) { _, _ in
            editedItemID = nil
            scrollPosition = ScrollPosition(idType: String.self)
        }
    }

    private func updateSets(_ update: () -> Void) {
        dismissKeyboard()
        let itemID = viewModel.viewedItemID
        let previousCount = viewModel.currentSetsTotal
        withAnimation(reduceMotion ? nil : Theme.setEditingAnimation) {
            update()
        }
        editedItemID = viewModel.currentSetsTotal != previousCount ? itemID : nil
    }

    private func dismissKeyboard() {
        let previous = focusedField
        focusedField = nil
        if let previous { viewModel.endNumberEditing(previous) }
    }

}
