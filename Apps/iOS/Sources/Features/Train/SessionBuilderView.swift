import SwiftUI

struct SessionBuilderView: View {
    @State var viewModel: SessionBuilderViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel

    var onSaved: (() -> Void)?
    var onDeleted: (() -> Void)?
    var onStart: ((WorkoutSnapshot) -> Void)?
    var onBack: (() -> Void)?
    var onSettings: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var openedInitialPicker = false
    @State private var showTargets = false
    @State private var showSettingsPrompt = false
    @State private var showDeletePrompt = false
    @State private var showDiscardPrompt = false
    @State private var isShowingExercisePicker = false
    @State private var dragLocation: CGPoint?

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: viewModel.isEditMode ? String(localized: .uiEditSession) : String(localized: .uiNewSession)) {
                    NavigationBackButton(action: requestBack)
                    .accessibilityIdentifier("builder.back")
                    .disabled(viewModel.isSaving)
                } trailing: {
                    if let onSettings {
                        Button(String(localized: .smartSettings)) {
                            if viewModel.hasUnsavedChanges { showSettingsPrompt = true } else { onSettings() }
                        }.frame(minHeight: Theme.touchSize).accessibilityIdentifier("smart.edit")
                            .disabled(viewModel.isSaving)
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        BuilderName(viewModel: viewModel)
                        if viewModel.mode == .smart && !viewModel.isDailySmart {
                            BuilderTargets(viewModel: viewModel)
                            Button(String(localized: .uiSelectMuscleGroups)) { showTargets = true }
                                .frame(minHeight: Theme.touchSize).padding(.horizontal, Theme.horizontalPadding)
                                .foregroundStyle(Theme.accent)
                        }
                        BuilderSmartInfo(viewModel: viewModel)
                        BuilderMovements(viewModel: viewModel, makeMovement: makeMovement,
                                         isShowingExercisePicker: $isShowingExercisePicker, dragLocation: $dragLocation)
                        BuilderDays(viewModel: viewModel)
                        BuilderTiming(viewModel: viewModel)
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
                    HStack(spacing: Theme.space12) {
                        if onStart != nil {
                            GhostButton(title: String(localized: .uiSave)) { handleSave(start: false) }
                                .disabled(!viewModel.canSave).accessibilityIdentifier("builder.save")
                            PrimaryButton(title: String(localized: .uiDesignStart), action: { handleSave(start: true) },
                                          disabled: !viewModel.canSave).accessibilityIdentifier("smart.start")
                        } else {
                            GlassActionButton(title: viewModel.isSaving ? String(localized: .uiDesignSaving) : String(localized: .uiSave),
                                              action: { handleSave(start: false) }, disabled: !viewModel.canSave)
                                .accessibilityIdentifier("builder.save")
                        }
                    }.padding(Theme.cardInset)
                }
            }
        }
        .sheet(isPresented: $isShowingExercisePicker) {
            ExercisePickerView(
                viewModel: ExercisePickerViewModel(exercises: viewModel.allExercises), makeMovement: makeMovement
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
        .background {
            if onBack != nil {
                BackActionSwipeBridge(isEnabled: !viewModel.isSaving, onBack: requestBack).allowsHitTesting(false)
            } else {
                BackSwipeBridge {
                    guard !viewModel.isSaving else { return false }
                    if viewModel.hasUnsavedChanges { showDiscardPrompt = true; return false }
                    return true
                }.allowsHitTesting(false)
            }
        }
        .alert(String(localized: .uiDiscardUnsavedChanges), isPresented: $showDiscardPrompt) {
            Button(String(localized: .uiDiscardChanges), role: .destructive, action: leaveEditor)
            Button(String(localized: .uiStay), role: .cancel) {}
        }
        .alert(String(localized: .uiDiscardUnsavedChanges), isPresented: $showSettingsPrompt) {
            Button(String(localized: .uiDiscardChanges), role: .destructive) { onSettings?() }
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
        if viewModel.hasUnsavedChanges { showDiscardPrompt = true } else { leaveEditor() }
    }

    private func leaveEditor() {
        if let onBack { onBack() } else { dismiss() }
    }

    private func handleSave(start: Bool) {
        Task {
            let success = await viewModel.save()
            if success {
                if start, let workout = viewModel.savedWorkout { onStart?(workout) } else if let onSaved { onSaved() } else { dismiss() }
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

    return SessionBuilderView(viewModel: viewModel, makeMovement: { MovementDetailViewModel(exercise: $0, allowsVideoLoading: false) })
        .preferredColorScheme(.dark)
}
#endif
