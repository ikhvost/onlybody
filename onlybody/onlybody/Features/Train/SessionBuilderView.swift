import SwiftUI

struct SessionBuilderView: View {
    @State var viewModel: SessionBuilderViewModel

    var onSaved: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var showDeletePrompt = false
    @State private var showDiscardPrompt = false
    @State private var isShowingExercisePicker = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: viewModel.isEditMode ? "Edit Session" : "New Session") {
                    Button {
                        requestBack()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
                    .accessibilityIdentifier("builder.back")
                    .disabled(viewModel.isSaving)
                } trailing: {
                    Button {
                        handleSave()
                    } label: {
                        Text("Save")
                        .font(Theme.fontSans(Theme.type15, .bold))
                            .foregroundStyle(Theme.accentDark)
                            .padding(.horizontal, Theme.space14)
                            .padding(.vertical, Theme.space6)
                            .background(Theme.accent)
                            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSaving)
                    .accessibilityIdentifier("builder.save")
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        BuilderTargets(viewModel: viewModel)
                        BuilderName(viewModel: viewModel)
                        BuilderStyle(viewModel: viewModel)
                        BuilderSmartInfo(viewModel: viewModel)
                        BuilderMovements(viewModel: viewModel, isShowingExercisePicker: $isShowingExercisePicker)
                        BuilderDays(viewModel: viewModel)
                        BuilderDuration(viewModel: viewModel)
                        if viewModel.isEditMode {
                            Button("Delete Workout", role: .destructive) { showDeletePrompt = true }
                                .font(Theme.fontSans(Theme.type15, .semibold))
                                .foregroundStyle(Theme.danger)
                                .padding(Theme.horizontalPadding)
                                .disabled(viewModel.isSaving)
                                .accessibilityIdentifier("builder.delete")
                        }
                    }
                    .padding(.bottom, Theme.space28)
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
        .background(BackSwipeBridge {
            guard !viewModel.isSaving else { return false }
            if viewModel.hasUnsavedChanges {
                showDiscardPrompt = true
                return false
            }
            return true
        }.allowsHitTesting(false))
        .alert("Discard unsaved changes?", isPresented: $showDiscardPrompt) {
            Button("Discard changes", role: .destructive) { dismiss() }
            Button("Stay", role: .cancel) {}
        }
        .alert("Delete workout?", isPresented: $showDeletePrompt) {
            Button("Delete Workout", role: .destructive) {
                Task {
                    if await viewModel.deleteWorkout() {
                        if let onSaved { onSaved() } else { dismiss() }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the saved workout template. Your training history, exercise results and activity will stay.")
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func requestBack() {
        guard !viewModel.isSaving else { return }
        if viewModel.hasUnsavedChanges { showDiscardPrompt = true } else { dismiss() }
    }

    private func handleSave() {
        Task {
            let success = await viewModel.save()
            if success {
                if let onSaved { onSaved() } else { dismiss() }
            }
        }
    }

}

#if DEBUG
#Preview("Session Builder — Create") {
    var pushUps = ExerciseSnapshot()
    pushUps.name = "Push-Ups"
    pushUps.primaryMuscle = "Chest"
    pushUps.equipment = ["None"]

    var pullUps = ExerciseSnapshot()
    pullUps.name = "Pull-Ups"
    pullUps.primaryMuscle = "Back"
    pullUps.equipment = ["Pull-up Bar"]

    let viewModel = SessionBuilderViewModel(
        workouts: PreviewWorkoutRepository(),
        exercises: PreviewExerciseRepository(exercises: [pushUps, pullUps]),
        workout: nil,
        targetMuscleGroups: []
    )

    return SessionBuilderView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
#endif
