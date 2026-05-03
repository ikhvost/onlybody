import SwiftUI

struct TrainView: View {
    let viewModel: TrainViewModel
    let showMusclePicker: () -> Void
    let showSessionBuilder: (UUID?) -> Void
    let showStreak: () -> Void
    let onStartWorkout: (UUID) -> Void

    private var contentState: String {
        if viewModel.isLoading { return "loading" }
        if viewModel.errorMessage != nil { return "error" }
        if viewModel.workouts.isEmpty { return "empty" }
        return "content"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                TrainHeader(
                    dateDisplay: viewModel.dateDisplay,
                    onCreateTap: {
                        showMusclePicker()
                    },
                    onTitleTap: {
                        showStreak()
                    }
                )

                ZStack {
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .tint(Theme.accent)
                            Spacer()
                        }
                        .transition(.opacity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            VStack(spacing: 10) {
                                MonoLabel(text: errorMessage, size: 10, color: Theme.text2, tracking: 0.4)
                                Button("Retry") {
                                    Task { await viewModel.load() }
                                }
                                .font(Theme.fontMono(13, .medium))
                                .foregroundStyle(Theme.accent)
                                .buttonStyle(PressableButtonStyle())
                            }
                            Spacer()
                        }
                        .transition(.opacity)
                    } else if viewModel.workouts.isEmpty {
                        VStack {
                            Spacer()
                            TrainEmptyState()
                            Spacer()
                        }
                        .transition(.opacity)
                    } else {
                        VStack(spacing: 0) {
                            TrainDayStrip(
                                dayNames: viewModel.dayNames,
                                todayIndex: viewModel.todayIndex,
                                workouts: viewModel.workouts
                            )
                            TodayCallout(
                                todaysWorkouts: viewModel.todaysWorkouts
                            )
                            WorkoutList(
                                workouts: viewModel.workouts,
                                todayName: viewModel.todayName,
                                onEdit: { workout in
                                    showSessionBuilder(workout.id)
                                },
                                onStart: { workout in
                                    onStartWorkout(workout.id)
                                }
                            )
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: contentState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
    }
}

#Preview("Train — placeholder") {
    TrainView(
        viewModel: TrainViewModel(
            workouts: PreviewWorkoutRepository()
        ),
        showMusclePicker: {},
        showSessionBuilder: { _ in },
        showStreak: {},
        onStartWorkout: { _ in }
    )
    .preferredColorScheme(.dark)
}

private struct TrainHeader: View {
    let dateDisplay: String
    let onCreateTap: () -> Void
    let onTitleTap: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Button {
                    onTitleTap()
                } label: {
                    MonoLabel(
                        text: dateDisplay,
                        size: 10,
                        color: Theme.text3,
                        tracking: 1.2
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Show streak")

                Button {
                    onTitleTap()
                } label: {
                    Text("OnlyBody")
                        .font(Theme.fontSans(28, .heavy))
                        .tracking(-1)
                        .foregroundStyle(Theme.text)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("OnlyBody — show streak")
            }

            Spacer()

            Button {
                onCreateTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.accent)
                        .frame(width: 38, height: 38)

                    PlusIcon(color: Theme.accentDark, size: 15)
                }
            }
            .accessibilityLabel("Create workout")
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }
}

private struct TrainEmptyState: View {
    var body: some View {
        VStack(spacing: 10) {
            MonoLabel(text: "No workouts yet", size: 11, color: Theme.text2, tracking: 1.0)
            Text("Tap the + button to create a workout")
                .font(Theme.fontSans(14))
                .foregroundStyle(Theme.text3)
        }
    }
}

private struct TrainDayStrip: View {
    let dayNames: [String]
    let todayIndex: Int
    let workouts: [Workout]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(dayNames.enumerated(), id: \.offset) { index, day in
                let isToday = index == todayIndex
                let hasWorkout = workouts.contains { $0.scheduledDays.contains(day) }

                VStack(spacing: 5) {
                    MonoLabel(
                        text: day,
                        size: 10,
                        color: isToday ? Theme.accent : Theme.text3,
                        tracking: 0.3
                    )

                    Rectangle()
                        .fill(hasWorkout ? (isToday ? Theme.accent : Theme.border2) : .clear)
                        .frame(width: 3, height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .overlay(alignment: .bottom) {
                    if isToday {
                        Rectangle()
                            .fill(Theme.accent)
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.bottom, 10)
    }
}

private struct TodayCallout: View {
    let todaysWorkouts: [Workout]

    var body: some View {
        Group {
            if todaysWorkouts.isEmpty {
                HStack {
                    Text("Rest day")
                        .font(Theme.fontMono(10))
                        .foregroundStyle(Theme.text3)
                        .tracking(1)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.border2)
                        .frame(width: 2)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 10)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    MonoLabel(text: "Today", size: 10, color: Theme.accent, tracking: 1)
                    Text(todaysWorkouts.map(\.name).joined(separator: " · "))
                        .font(Theme.fontSans(14, .bold))
                        .foregroundStyle(Theme.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.accentDim)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.accent)
                        .frame(width: 2)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 10)
            }
        }
    }
}

private struct WorkoutList: View {
    let workouts: [Workout]
    let todayName: String
    let onEdit: (Workout) -> Void
    let onStart: (Workout) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(workouts) { workout in
                    WorkoutRow(
                        workout: workout,
                        isToday: workout.scheduledDays.contains(todayName),
                        onEditTap: { onEdit(workout) },
                        onStartTap: { onStart(workout) }
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
    }
}

private struct WorkoutRow: View {
    let workout: Workout
    let isToday: Bool
    let onEditTap: () -> Void
    let onStartTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(workout.name)
                    .font(Theme.fontSans(16, .bold))
                    .foregroundStyle(Theme.text)

                MonoLabel(
                    text: "\(workout.scheduledDays.isEmpty ? "UNSCHEDULED" : workout.scheduledDays.joined(separator: " · "))  ·  \(workout.items?.count ?? 0) MVMTS",
                    size: 9,
                    color: Theme.text3,
                    tracking: 0.5
                )
            }

            Spacer()

            Button {
                onEditTap()
            } label: {
                EditIcon(color: Theme.text3, size: 15)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Edit \(workout.name)")
            .padding(6)

            Button {
                onStartTap()
            } label: {
                Text("START →")
                    .tracking(1.2)
                    .font(Theme.fontMono(12, .medium))
                    .foregroundStyle(Theme.accentDark)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Start \(workout.name)")
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(Theme.accent)
            .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, Theme.horizontalPadding)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isToday ? Theme.accent : .clear)
                .frame(width: 2)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
                .padding(.leading, Theme.horizontalPadding)
        }
    }
}
