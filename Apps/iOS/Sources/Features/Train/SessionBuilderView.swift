import SwiftUI

struct SessionBuilderView: View {
    @State var viewModel: SessionBuilderViewModel

    var onSaved: (() -> Void)?
    var onDeleted: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var openedInitialPicker = false
    @State private var showTargets = false
    @State private var showDeletePrompt = false
    @State private var showDiscardPrompt = false
    @State private var isShowingExercisePicker = false
    @State private var dragLocation: CGPoint?

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: viewModel.isEditMode ? String(localized: .uiEditSession) : String(localized: .uiNewSession)) {
                    Button {
                        requestBack()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                            .frame(width: Theme.touchSize, height: Theme.touchSize)
                            .contentShape(.rect)
                    }
                    .buttonStyle(PressableButtonStyle(animates: false))
                    .accessibilityLabel(String(localized: .uiBack))
                    .accessibilityIdentifier("builder.back")
                    .disabled(viewModel.isSaving)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        BuilderName(viewModel: viewModel)
                        BuilderStyle(viewModel: viewModel)
                        if viewModel.mode == .smart {
                            BuilderTargets(viewModel: viewModel)
                            Button(String(localized: .uiSelectMuscleGroups)) { showTargets = true }
                                .frame(minHeight: Theme.touchSize).padding(.horizontal, Theme.horizontalPadding)
                                .foregroundStyle(Theme.accent)
                        }
                        BuilderSmartInfo(viewModel: viewModel)
                        BuilderMovements(viewModel: viewModel, isShowingExercisePicker: $isShowingExercisePicker, dragLocation: $dragLocation)
                        DisclosureGroup {
                            BuilderDays(viewModel: viewModel)
                        } label: {
                            Text(.uiDesignSchedule).frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                        }
                        .font(Theme.fontSans(Theme.typeBody)).padding(Theme.horizontalPadding)
                        DisclosureGroup {
                            BuilderTiming(viewModel: viewModel)
                        } label: {
                            Text(.uiDesignOptions)
                                .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                                .accessibilityIdentifier("builder.options")
                        }
                        .font(Theme.fontSans(Theme.typeBody)).padding(Theme.horizontalPadding)
                        BuilderDuration(viewModel: viewModel)
                        if viewModel.isEditMode {
                            Button(String(localized: .uiDeleteWorkout), role: .destructive) { showDeletePrompt = true }
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
                .modifier(ExerciseReorderAutoScroll(location: $dragLocation))
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom, spacing: Theme.space0) {
                    PrimaryButton(title: viewModel.isSaving ? String(localized: .uiDesignSaving) : String(localized: .uiSave),
                                  action: handleSave, disabled: viewModel.isLoading || viewModel.isSaving || viewModel.hasInvalidNumbers)
                        .accessibilityIdentifier("builder.save").padding(Theme.cardInset).background(Theme.bg)
                }
            }
        }
        .sheet(isPresented: $isShowingExercisePicker) {
            ExercisePickerView(
                viewModel: ExercisePickerViewModel(exercises: viewModel.allExercises)
            ) { exercise in
                viewModel.addMovement(exercise)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showTargets) {
            BuilderTargetPicker(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .task {
            await viewModel.loadExercises()
            if !viewModel.isEditMode, viewModel.mode == .manual, !openedInitialPicker, viewModel.errorMessage == nil {
                openedInitialPicker = true
                isShowingExercisePicker = true
            }
        }
        .alert(String(localized: .uiError), isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button(String(localized: .uiOkUppercase)) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .foregroundStyle(Theme.text)
        .background(BackSwipeBridge {
            guard !viewModel.isSaving else { return false }
            if viewModel.hasUnsavedChanges {
                showDiscardPrompt = true
                return false
            }
            return true
        }.allowsHitTesting(false))
        .alert(String(localized: .uiDiscardUnsavedChanges), isPresented: $showDiscardPrompt) {
            Button(String(localized: .uiDiscardChanges), role: .destructive) { dismiss() }
            Button(String(localized: .uiStay), role: .cancel) {}
        }
        .alert(String(localized: .uiDeleteWorkoutMessage4Dbb), isPresented: $showDeletePrompt) {
            Button(String(localized: .uiDeleteWorkout), role: .destructive) {
                Task {
                    if await viewModel.deleteWorkout() {
                        if let onDeleted { onDeleted() } else if let onSaved { onSaved() } else { dismiss() }
                    }
                }
            }
            Button(String(localized: .uiCancel), role: .cancel) {}
        } message: {
            Text(.uiThisRemovesTheSavedWorkoutTemplateYourTrainingHistoryExercise)
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
