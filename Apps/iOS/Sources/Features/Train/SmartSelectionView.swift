import SwiftUI

struct SmartSelectionView: View {
    @State var viewModel: SmartSelectionViewModel
    let onSaved: () -> Void
    let onStart: (WorkoutSnapshot) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var confirmDiscard = false
    @State private var confirmDelete = false
    @State private var dragLocation: CGPoint?
    @State private var replacement: WorkoutItemSnapshot?

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: String(localized: .smartSmart)) {
                NavigationBackButton(action: requestBack).accessibilityIdentifier("smart.back")
            } trailing: {
                if viewModel.stage == .preview {
                    Button(String(localized: .uiDesignEdit)) { viewModel.edit() }
                        .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize).accessibilityIdentifier("smart.edit")
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionGap) {
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundStyle(Theme.danger)
                        GhostButton(title: String(localized: .uiRetry)) { Task { await viewModel.retry() } }
                    }
                    switch viewModel.stage {
                    case .setup: SmartSetupView(viewModel: viewModel)
                    case .conditions: SmartConditionsView(viewModel: viewModel)
                    case .preview: SmartDailyPreviewView(viewModel: viewModel, dragLocation: $dragLocation, onReplace: { replacement = $0 })
                    }
                    if viewModel.isExisting, viewModel.stage == .setup {
                        Button(String(localized: .uiDeleteWorkout), role: .destructive) { confirmDelete = true }
                            .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize).foregroundStyle(Theme.danger)
                    }
                }.padding(Theme.horizontalPadding)
            }.scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
                .modifier(ExerciseReorderAutoScroll(location: $dragLocation))
                .safeAreaInset(edge: .bottom, spacing: Theme.space0) {
                    VStack(spacing: Theme.space8) {
                        switch viewModel.stage {
                        case .setup:
                            GlassActionButton(title: String(localized: .smartNext), action: { viewModel.showConditions() },
                                              disabled: !viewModel.hasValidTargets || viewModel.isBusy)
                                .accessibilityIdentifier("smart.continue")
                        case .conditions:
                            GlassActionButton(title: String(localized: .smartPreview), action: { Task { await viewModel.preview() } },
                                              disabled: viewModel.isBusy).accessibilityIdentifier("smart.preview")
                        case .preview:
                            if viewModel.needsShortPlanAcceptance {
                                GhostButton(title: String(localized: .smartAcceptShortPlan)) {
                                    Task { await viewModel.acceptShortPlan() }
                                }.accessibilityIdentifier("smart.acceptShortPlan")
                            }
                            HStack(spacing: Theme.space12) {
                                GhostButton(title: String(localized: .uiSave)) {
                                    Task { if await viewModel.save() != nil { onSaved() } }
                                }.disabled(!viewModel.canStart).accessibilityIdentifier("smart.save")
                                PrimaryButton(title: String(localized: .uiDesignStart), action: {
                                    Task { if let workout = await viewModel.save() { onStart(workout) } }
                                }, disabled: !viewModel.canStart).accessibilityIdentifier("smart.start")
                            }
                        }
                    }.padding(Theme.cardInset)
                }
        }
        .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text).tint(Theme.accent)
        .background(Theme.bg.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        .disabled(viewModel.isBusy)
        .overlay { if viewModel.isBusy { ProgressView().tint(Theme.accent) } }
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await viewModel.refreshDay() } } }
        .background {
            if viewModel.hasPreviousStep {
                BackActionSwipeBridge(isEnabled: !viewModel.isBusy && replacement == nil, onBack: requestBack).allowsHitTesting(false)
            } else {
                BackSwipeBridge {
                    guard !viewModel.isBusy else { return false }
                    if viewModel.hasUnsavedChanges { confirmDiscard = true; return false }
                    return true
                }.allowsHitTesting(false)
            }
        }
        .alert(String(localized: .uiDiscardUnsavedChanges), isPresented: $confirmDiscard) {
            Button(String(localized: .uiDiscardChanges), role: .destructive) { dismiss() }
            Button(String(localized: .uiStay), role: .cancel) {}
        }
        .alert(String(localized: .uiDeleteWorkoutMessage4Dbb), isPresented: $confirmDelete) {
            Button(String(localized: .uiDeleteWorkout), role: .destructive) {
                Task { if await viewModel.delete() { onSaved() } }
            }
            Button(String(localized: .uiCancel), role: .cancel) {}
        } message: { Text(.uiThisRemovesTheSavedWorkoutTemplateYourTrainingHistoryExercise) }
        .sheet(item: $replacement) { item in
            SmartReplacementView(viewModel: SmartReplacementViewModel(
                item: item, items: viewModel.variant?.items ?? [], configuration: viewModel.configuration, catalog: viewModel.catalog),
                onReplace: { exercise in
                    Task { await viewModel.replace(item.id, with: exercise) }
                },
                onExclude: {
                    guard let exercise = item.exercise else { return false }
                    return await viewModel.exclude(exercise)
                })
        }
    }

    private func requestBack() {
        guard !viewModel.isBusy else { return }
        if viewModel.hasPreviousStep { Task { await viewModel.goBack() } } else if viewModel.hasUnsavedChanges { confirmDiscard = true } else { dismiss() }
    }

}

#if DEBUG
#Preview {
    SmartSelectionView(viewModel: SmartSelectionViewModel(workouts: PreviewWorkoutRepository(),
        exercises: PreviewExerciseRepository(exercises: [ExerciseSnapshot(name: "Push-Ups", primaryMuscle: "Chest", equipment: ["None"])]),
        variants: PreviewSmartDailyVariantRepository(), preferences: WorkoutPreferences(), targets: ["Chest"]),
        onSaved: {}, onStart: { _ in }).preferredColorScheme(.dark)
}
#endif
