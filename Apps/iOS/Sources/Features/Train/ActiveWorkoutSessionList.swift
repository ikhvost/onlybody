import SwiftUI

struct ActiveWorkoutSessionList: View {
    let viewModel: ActiveWorkoutViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let onClose: () -> Void
    let onEnd: () -> Void
    @State private var dragLocation: CGPoint?
    @State private var replacementItem: WorkoutItemSnapshot?

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView {
                if !viewModel.hasStarted {
                    Button(action: onClose) {
                        ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize)
                    }.accessibilityLabel(String(localized: .uiBack)).accessibilityIdentifier("active.back")
                }
            } trailing: {
                Button(viewModel.hasStarted ? String(localized: .uiWorkoutResume) : String(localized: .uiDesignStart)) {
                    if viewModel.hasStarted { viewModel.resume() } else { viewModel.beginSession() }
                }
                .font(Theme.fontSans(Theme.typeMeta, .bold)).foregroundStyle(Theme.accentDark)
                .padding(.horizontal, Theme.space12).frame(minHeight: Theme.touchSize)
                .background(Theme.accent, in: .capsule)
                .disabled(viewModel.allSetsCompleted || viewModel.hasInvalidNumbers)
                .accessibilityIdentifier(viewModel.hasStarted ? "active.resume" : "active.start")
            }
            if viewModel.hasStarted {
                Text(Duration.seconds(viewModel.elapsedSeconds), format: .time(pattern: .minuteSecond(padMinuteToLength: 2)))
                    .font(Theme.fontMono(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    .padding(.vertical, Theme.space8)
            }
            CompactRestTimerView(viewModel: viewModel)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.space12) {
                    Text(.uiWorkoutToday).font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    Text(viewModel.workoutName).font(Theme.fontSans(Theme.typeHeading, .bold))
                    Text(.uiWorkoutSessionOnly).font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    if viewModel.allSetsCompleted {
                        Text(.uiWorkoutReady).foregroundStyle(Theme.accent)
                            .padding(Theme.cardInset).background(Theme.accentDim, in: .rect(cornerRadius: Theme.cornerRadius))
                    }
                    ExerciseReorderStack(items: viewModel.items, spacing: Theme.space12, isEnabled: !viewModel.hasInvalidNumbers,
                                         dragLocation: $dragLocation, onMove: viewModel.moveExercise) { item, handle in
                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                            ActiveWorkoutSessionCard(viewModel: viewModel, item: item, index: index, reorderHandle: handle) {
                                replacementItem = item
                            }
                        }
                    }
                }
                .padding(Theme.horizontalPadding)
            }
            .scrollIndicators(.hidden)
            .modifier(ExerciseReorderAutoScroll(location: $dragLocation))
            if viewModel.hasStarted {
                PrimaryButton(title: String(localized: .uiEndWorkout), action: onEnd)
                    .accessibilityIdentifier("active.end").padding(Theme.cardInset).background(Theme.bg)
            }
        }
        .background(BackActionSwipeBridge(isEnabled: !viewModel.hasStarted, onBack: onClose).allowsHitTesting(false))
        .sheet(item: $replacementItem) { item in
            ActiveWorkoutReplacementView(viewModel: viewModel, makeMovement: makeMovement, itemID: item.id)
                .presentationDetents([.large]).presentationDragIndicator(.hidden)
        }
    }
}
