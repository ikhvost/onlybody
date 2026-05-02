import SwiftUI

struct SessionBuilderView: View {
    @Bindable var viewModel: SessionBuilderViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var isShowingExercisePicker = false

    private var title: String {
        viewModel.isEditMode ? "Edit Session" : "New Session"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: title) {
                    Button {
                        dismiss()
                    } label: {
                        BackIcon(color: Theme.text, size: 18)
                    }
                    .buttonStyle(.plain)
                } trailing: {
                    Button {
                        handleSave()
                    } label: {
                        Text("Save")
                            .font(Theme.fontSans(13, .bold))
                            .foregroundStyle(Theme.accentDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Theme.accent)
                            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSaving)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        targetChipsSection
                        nameSection
                        setStyleSection
                        smartInfoSection
                        movementsSection
                        trainingDaysSection
                        durationSection
                    }
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $isShowingExercisePicker) {
            ExercisePickerView(
                exercises: viewModel.allExercises
            ) { exercise in
                viewModel.addMovement(exercise)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .task {
            await viewModel.loadExercises()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func handleSave() {
        Task {
            let success = await viewModel.save()
            if success {
                dismiss()
            }
        }
    }

    // MARK: - Target Chips

    @ViewBuilder
    private var targetChipsSection: some View {
        if !viewModel.targetMuscleGroups.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                MonoLabel(text: "Targets", size: 10, color: Theme.text2, tracking: 0.5)

                FlowLayout(spacing: 6) {
                    ForEach(viewModel.targetMuscleGroups, id: \.self) { muscleID in
                        Text(muscleID)
                            .font(Theme.fontSans(12, .semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Theme.accentDim)
                            .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                            .overlay {
                                RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                                    .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                            }
                    }
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 16)
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "Session name", size: 10, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding)

            TextField("e.g. Full Body", text: $viewModel.name)
                .font(Theme.fontSans(15))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 13)
                .padding(.vertical, 11)
                .background(Theme.surface)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.top, 16)
    }

    // MARK: - Set Style

    private var setStyleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "Set style", size: 10, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding)

            HStack(spacing: 8) {
                modeButton("Smart pick", mode: "smart")
                modeButton("I choose", mode: "manual")
            }
            .padding(.horizontal, Theme.horizontalPadding)
        }
        .padding(.top, 16)
    }

    private func modeButton(_ label: String, mode: String) -> some View {
        Button {
            viewModel.mode = mode
        } label: {
            Text(label)
                .font(Theme.fontSans(13, .semibold))
                .foregroundStyle(viewModel.mode == mode ? Theme.accentDark : Theme.text2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(viewModel.mode == mode ? Theme.accent : Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(
                            viewModel.mode == mode ? Theme.accent : Theme.border2,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Smart Info

    @ViewBuilder
    private var smartInfoSection: some View {
        if viewModel.mode == "smart" {
            VStack(alignment: .leading, spacing: 4) {
                Text("Auto-selected movements")
                    .font(Theme.fontSans(13, .bold))
                    .foregroundStyle(Theme.text)

                Text(smartInfoDescription)
                    .font(Theme.fontSans(12))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.border, lineWidth: 1)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 14)
        }
    }

    private var smartInfoDescription: String {
        if viewModel.targetMuscleGroups.isEmpty {
            return "Movements are picked daily from your targets. Switch to \"I choose\" to build manually."
        }

        let formatted = viewModel.targetMuscleGroups.joined(separator: ", ")
        return "Movements are picked daily from your targets (\(formatted)). Switch to \"I choose\" to build manually."
    }

    // MARK: - Movements

    @ViewBuilder
    private var movementsSection: some View {
        if viewModel.mode == "manual" {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MonoLabel(text: "Movements", size: 10, color: Theme.text2, tracking: 0.5)
                    Spacer()
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        HStack(spacing: 5) {
                            PlusIcon(color: Theme.accentDark, size: 12)
                            Text("Add")
                                .font(Theme.fontSans(12, .bold))
                                .foregroundStyle(Theme.accentDark)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.horizontalPadding)

                if viewModel.movements.isEmpty {
                    MonoLabel(
                        text: "No movements yet",
                        size: 10,
                        color: Theme.text3,
                        tracking: 0.5
                    )
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .background(Theme.surface)
                    .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Theme.border2)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                } else {
                    VStack(spacing: 6) {
                        ForEach(viewModel.movements) { movement in
                            movementCard(movement)
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                }
            }
            .padding(.top, 16)
        }
    }

    private func movementCard(_ movement: MovementConfig) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(movement.exercise.name)
                        .font(Theme.fontSans(14, .bold))
                        .foregroundStyle(Theme.text)

                    MonoLabel(
                        text: "\(movement.sets) SETS · \(movement.reps) REPS · \(movement.restSeconds)S REST",
                        size: 9,
                        color: Theme.text3,
                        tracking: 0.4
                    )
                }

                Spacer()

                Button {
                    viewModel.removeMovement(movement.id)
                } label: {
                    RemoveIcon(color: Theme.danger, size: 15)
                }
                .buttonStyle(.plain)
                .padding(4)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 11)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            HStack(spacing: 10) {
                StepperView(
                    label: "Sets",
                    value: movement.sets,
                    step: 1,
                    minValue: 1,
                    format: { "\($0)" },
                    onIncrement: { viewModel.setSets(movement.sets + 1, forMovement: movement.id) },
                    onDecrement: { viewModel.setSets(movement.sets - 1, forMovement: movement.id) }
                )

                StepperView(
                    label: "Reps",
                    value: movement.reps,
                    step: 1,
                    minValue: 1,
                    format: { "\($0)" },
                    onIncrement: { viewModel.setReps(movement.reps + 1, forMovement: movement.id) },
                    onDecrement: { viewModel.setReps(movement.reps - 1, forMovement: movement.id) }
                )

                StepperView(
                    label: "Rest",
                    value: movement.restSeconds,
                    step: 15,
                    minValue: 15,
                    format: { "\($0)s" },
                    onIncrement: { viewModel.setRest(movement.restSeconds + 15, forMovement: movement.id) },
                    onDecrement: { viewModel.setRest(movement.restSeconds - 15, forMovement: movement.id) }
                )
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        }
    }

    // MARK: - Training Days

    private var trainingDaysSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "Training days", size: 10, color: Theme.text2, tracking: 0.5)

            HStack(spacing: 6) {
                ForEach(viewModel.dayNames, id: \.self) { day in
                    ChipView(
                        label: day,
                        isActive: viewModel.scheduledDays.contains(day),
                        isSmall: true
                    ) {
                        viewModel.toggleDay(day)
                    }
                }
            }

            if viewModel.scheduledDays.isEmpty {
                MonoLabel(
                    text: "No days scheduled",
                    size: 10,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, 16)
    }

    // MARK: - Duration

    @ViewBuilder
    private var durationSection: some View {
        if !viewModel.movements.isEmpty {
            HStack {
                Text("Est. duration")
                    .font(Theme.fontSans(13))
                    .foregroundStyle(Theme.text2)

                Spacer()

                Text("~\(viewModel.estimatedDurationMinutes) min")
                    .font(Theme.fontMono(13, .medium))
                    .foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 14)
                .padding(.bottom, 10)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Theme.border)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.horizontalPadding)
                }
            }
    }

}

#Preview("Session Builder — Create") {
    let viewModel = SessionBuilderViewModel(
        workouts: PreviewWorkoutRepository(),
        exercises: PreviewExerciseRepository(),
        workout: nil,
        targetMuscleGroups: []
    )

    let pushUps = Exercise()
    pushUps.name = "Push-Ups"
    pushUps.primaryMuscle = "Chest"
    pushUps.equipment = ["None"]

    let pullUps = Exercise()
    pullUps.name = "Pull-Ups"
    pullUps.primaryMuscle = "Back"
    pullUps.equipment = ["Pull-up Bar"]

    viewModel.allExercises = [pushUps, pullUps]

    return SessionBuilderView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

private struct PreviewWorkoutRepository: WorkoutRepository {
    func allWorkouts() async throws -> [Workout] { [] }
    func workout(by id: UUID) async throws -> Workout? { nil }
    func save(_ workout: Workout) async throws {}
    func deleteItems(_ items: [WorkoutItem]) async throws {}
}

private struct PreviewExerciseRepository: ExerciseRepository {
    func allExercises() async throws -> [Exercise] { [] }
    func save(_ exercise: Exercise) async throws {}
}
