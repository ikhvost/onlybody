import SwiftUI

struct ActiveWorkoutSessionList: View {
    let viewModel: ActiveWorkoutViewModel
    let onClose: () -> Void
    let onEnd: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var replacementItem: WorkoutItemSnapshot?

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: String(localized: .uiWorkoutToday)) {
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
                .background(Theme.accent, in: .rect(cornerRadius: Theme.buttonRadius))
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
                LazyVStack(alignment: .leading, spacing: Theme.space12) {
                    Text(viewModel.workoutName).font(Theme.fontSans(Theme.typeExercise, .bold))
                    Text(.uiWorkoutSessionOnly).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    if viewModel.allSetsCompleted {
                        Text(.uiWorkoutReady).foregroundStyle(Theme.accent)
                            .padding(Theme.cardInset).background(Theme.accentDim, in: .rect(cornerRadius: Theme.cornerRadius))
                    }
                    ForEach(viewModel.items.enumerated(), id: \.element.id) { index, item in
                        ActiveWorkoutSessionCard(viewModel: viewModel, item: item, index: index) { replacementItem = item }
                    }
                }
                .padding(Theme.horizontalPadding)
                .animation(reduceMotion ? nil : .smooth(duration: Theme.exerciseReorderDuration), value: viewModel.items.map(\.id))
            }.scrollIndicators(.hidden)
            if viewModel.hasStarted {
                PrimaryButton(title: String(localized: .uiEndWorkout), action: onEnd)
                    .accessibilityIdentifier("active.end").padding(Theme.cardInset).background(Theme.bg)
            }
        }
        .sheet(item: $replacementItem) { item in
            ActiveWorkoutReplacementView(viewModel: viewModel, itemID: item.id)
                .presentationDetents([.large]).presentationDragIndicator(.hidden)
        }
    }
}
