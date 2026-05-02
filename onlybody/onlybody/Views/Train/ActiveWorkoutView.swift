import SwiftUI

struct ActiveWorkoutView: View {
    let viewModel: ActiveWorkoutViewModel
    let onEnd: () -> Void

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
                    exerciseCount: viewModel.items.count,
                    errorMessage: viewModel.errorMessage,
                    onEnd: onEnd
                )
            } else if !viewModel.items.isEmpty {
                ActiveWorkoutBody(
                    currentIndex: viewModel.currentExerciseIndex,
                    totalCount: viewModel.items.count,
                    elapsedString: formatTime(viewModel.elapsedSeconds),
                    exerciseName: viewModel.currentExerciseName,
                    setLabel: setLabel,
                    totalSets: viewModel.currentSetsTotal,
                    completedSets: viewModel.completedSetsForCurrent,
                    currentSetIndex: viewModel.currentSetIndex,
                    reps: viewModel.currentDisplayReps,
                    weight: viewModel.currentWeight,
                    errorMessage: viewModel.errorMessage,
                    canGoPrevious: viewModel.canGoPrevious,
                    canSkip: viewModel.canSkip,
                    nextExerciseName: viewModel.nextExerciseName,
                    isRestActive: viewModel.restTimer.isActive,
                    restSecondsString: formatTime(viewModel.restTimer.remainingSeconds),
                    restNextName: viewModel.restTimer.nextExerciseName,
                    onEnd: { showEndPrompt = true },
                    onMarkSetDone: { viewModel.markSetDone() },
                    onIncrementReps: { viewModel.incrementReps() },
                    onDecrementReps: { viewModel.decrementReps() },
                    onIncrementWeight: { viewModel.incrementWeight() },
                    onDecrementWeight: { viewModel.decrementWeight() },
                    onPreviousExercise: { viewModel.previousExercise() },
                    onSkipExercise: { viewModel.skipExercise() },
                    onSkipRest: { viewModel.restTimer.skip() }
                )
            }
        }
        .alert("End workout?", isPresented: $showEndPrompt) {
            Button("End & Save", role: .destructive) {
                Task {
                    await viewModel.endSession()
                    if viewModel.errorMessage == nil {
                        onEnd()
                    }
                }
            }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Completed sets will be saved.")
        }
        .task {
            await viewModel.load()
        }
    }

    private var setLabel: String {
        let target = viewModel.currentTargetReps > 0
            ? "Target \(viewModel.currentTargetReps) reps"
            : "max hold"
        return "Set \(viewModel.currentSetIndex + 1) of \(viewModel.currentSetsTotal) \u{00B7} \(target)"
    }

    private func formatTime(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
}

private struct ActiveWorkoutLoadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(Theme.accent)
            MonoLabel(text: "Preparing workout", size: 10, color: Theme.text3, tracking: 1)
        }
    }
}

private struct ActiveWorkoutErrorView: View {
    let errorMessage: String?
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            MonoLabel(text: "Workout unavailable", size: 10, color: Theme.text2, tracking: 0.4)
            if let error = errorMessage {
                MonoLabel(text: error, size: 9, color: Theme.text3, tracking: 0.4)
            }
            GhostButton(title: "Close", action: onEnd)
        }
    }
}

private struct ActiveWorkoutCompletionView: View {
    let elapsedString: String
    let exerciseCount: Int
    let errorMessage: String?
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            MonoLabel(text: "Session complete", size: 10, color: Theme.text3, tracking: 2)

            Text(elapsedString)
                .font(Theme.fontMono(72, .medium))
                .foregroundStyle(Theme.accent)
                .tracking(-3)
                .lineLimit(1)
                .padding(.top, 12)

            MonoLabel(
                text: "\(exerciseCount) movements done",
                size: 11,
                color: Theme.text2,
                tracking: 1
            )
            .padding(.top, 10)

            if let error = errorMessage {
                MonoLabel(
                    text: error,
                    size: 9,
                    color: Theme.danger,
                    tracking: 0.4
                )
                .padding(.top, 10)
            }

            PrimaryButton(title: "Close") {
                onEnd()
            }
            .frame(maxWidth: 200)
            .padding(.top, 48)

            Spacer()
        }
        .padding(.horizontal, Theme.horizontalPadding)
    }
}

private struct ActiveWorkoutBody: View {
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
            VStack(spacing: 0) {
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
                        size: 9,
                        color: Theme.danger,
                        tracking: 0.4
                    )
                    .padding(.top, 4)
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

private struct ActiveWorkoutTopBar: View {
    let currentIndex: Int
    let totalCount: Int
    let elapsedString: String
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            MonoLabel(
                text: "\(currentIndex + 1)/\(totalCount)",
                size: 11,
                color: Theme.text3,
                tracking: 0.5
            )

            Spacer()

            Text(elapsedString)
                .font(Theme.fontMono(15, .regular))
                .foregroundStyle(Theme.text2)
                .tracking(-0.5)

            Spacer()

            GhostButton(title: "End", action: onEnd)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

private struct ActiveWorkoutProgressBar: View {
    let currentIndex: Int
    let totalCount: Int

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Theme.surface2)
                .frame(height: 2)

            Rectangle()
                .fill(Theme.accent)
                .frame(height: 2)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * CGFloat(currentIndex) / CGFloat(max(1, totalCount))
                }
                .animation(.easeInOut(duration: 0.4), value: currentIndex)
        }
    }
}

private struct ActiveWorkoutExerciseContent: View {
    let exerciseName: String
    let setLabel: String
    let totalSets: Int
    let completedSets: Int
    let currentSetIndex: Int
    let reps: Int
    let weight: Double
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

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ActiveWorkoutExerciseHeader(
                        exerciseName: exerciseName,
                        setLabel: setLabel
                    )
                    .padding(.horizontal, Theme.horizontalPadding)

                    SetTrackerView(
                        total: totalSets,
                        completed: completedSets,
                        current: currentSetIndex
                    )
                    .padding(.top, 28)
                    .padding(.horizontal, Theme.horizontalPadding)

                    ActiveWorkoutStepperCards(
                        reps: reps,
                        weight: weight,
                        onIncrementReps: onIncrementReps,
                        onDecrementReps: onDecrementReps,
                        onIncrementWeight: onIncrementWeight,
                        onDecrementWeight: onDecrementWeight
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, Theme.horizontalPadding)

                    ActiveWorkoutExerciseNavigation(
                        canGoPrevious: canGoPrevious,
                        canSkip: canSkip,
                        onPrevious: onPreviousExercise,
                        onSkip: onSkipExercise
                    )
                    .padding(.top, 14)
                    .padding(.horizontal, Theme.horizontalPadding)
                }
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)

            if canSkip {
                ActiveWorkoutUpNextSection(nextExerciseName: nextExerciseName)
            }

            PrimaryButton(title: "Mark Set Done") {
                onMarkSetDone()
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.bottom, 18)
            .padding(.top, 8)
        }
    }
}

private struct ActiveWorkoutExerciseHeader: View {
    let exerciseName: String
    let setLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exerciseName)
                .font(Theme.fontSans(38, .heavy))
                .tracking(-1.5)
                .foregroundStyle(Theme.text)
                .lineSpacing(0)

            MonoLabel(
                text: setLabel,
                size: 10,
                color: Theme.text3,
                tracking: 0.8
            )
            .padding(.top, 22)
        }
    }
}

private struct ActiveWorkoutStepperCards: View {
    let reps: Int
    let weight: Double
    let onIncrementReps: () -> Void
    let onDecrementReps: () -> Void
    let onIncrementWeight: () -> Void
    let onDecrementWeight: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ActiveWorkoutRepsCard(
                reps: reps,
                onIncrement: onIncrementReps,
                onDecrement: onDecrementReps
            )
            ActiveWorkoutWeightCard(
                weight: weight,
                onIncrement: onIncrementWeight,
                onDecrement: onDecrementWeight
            )
        }
    }
}

private struct ActiveWorkoutRepsCard: View {
    let reps: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        StepperView(
            label: "Reps",
            value: reps,
            step: 1,
            minValue: 0,
            format: { "\($0)" },
            onIncrement: onIncrement,
            onDecrement: onDecrement
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Theme.surface)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}

private struct ActiveWorkoutWeightCard: View {
    let weight: Double
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            MonoLabel(text: "Added kg", size: 9, color: Theme.text3, tracking: 0.5)

            HStack(spacing: 4) {
                Button {
                    onDecrement()
                } label: {
                    Text("\u{2212}")
                        .font(Theme.fontMono(14, .medium))
                        .foregroundStyle(weight > 0 ? Theme.text : Theme.text3)
                        .frame(width: 24, height: 24)
                        .background(Theme.surface2)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                                .stroke(Theme.border2, lineWidth: 1)
                        }
                }
                .disabled(weight <= 0)
                .buttonStyle(.plain)

                Text(formatWeight(weight))
                    .font(Theme.fontMono(14, .bold))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)

                Button {
                    onIncrement()
                } label: {
                    Text("+")
                        .font(Theme.fontMono(14, .medium))
                        .foregroundStyle(Theme.accentDark)
                        .frame(width: 24, height: 24)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Theme.surface)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }

    private func formatWeight(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)).grouping(.never))
    }
}

private struct ActiveWorkoutExerciseNavigation: View {
    let canGoPrevious: Bool
    let canSkip: Bool
    let onPrevious: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if canGoPrevious {
                GhostButton(title: "\u{2190} Prev") {
                    onPrevious()
                }
                .frame(maxWidth: .infinity)
            }

            if canSkip {
                GhostButton(title: "Skip \u{2192}") {
                    onSkip()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ActiveWorkoutUpNextSection: View {
    let nextExerciseName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            MonoLabel(text: "Up next", size: 9, color: Theme.text3, tracking: 0.5)
            Text(nextExerciseName)
                .font(Theme.fontSans(13, .semibold))
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, 8)
    }
}

private struct RestOverlayView: View {
    let remainingString: String
    let nextExerciseName: String
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                MonoLabel(text: "Recovery", size: 10, color: Theme.text3, tracking: 3)
                    .padding(.bottom, 18)

                Text(remainingString)
                    .font(Theme.fontMono(84, .medium))
                    .foregroundStyle(Theme.accent)
                    .tracking(-4)
                    .lineLimit(1)

                if !nextExerciseName.isEmpty {
                    MonoLabel(
                        text: "next \u{2014} \(nextExerciseName)",
                        size: 10,
                        color: Theme.text3,
                        tracking: 1.5
                    )
                    .padding(.top, 18)
                }

                GhostButton(title: "Skip rest") {
                    onSkip()
                }
                .padding(.top, 44)
            }
        }
    }
}
