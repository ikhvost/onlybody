import SwiftUI

struct SmartSelectionView: View {
    @State var viewModel: SmartSelectionViewModel
    let makeBuilder: (SmartEditorContext) -> SessionBuilderViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let onSaved: () -> Void
    let onStart: (WorkoutSnapshot) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDiscard = false

    var body: some View {
        Group {
            if viewModel.stage == .preview, let context = viewModel.editorContext {
                let editorBack: (() -> Void)? = context.isExisting ? nil : { viewModel.backFromEditor() }
                SessionBuilderView(viewModel: makeBuilder(context), makeMovement: makeMovement,
                                   onSaved: onSaved, onDeleted: onSaved, onStart: onStart,
                                   onBack: editorBack, onSettings: { viewModel.edit() })
                    .id(context.id)
            } else {
                VStack(spacing: Theme.space0) {
                    NavBarView(title: String(localized: .smartSmart)) {
                        NavigationBackButton(action: requestBack).accessibilityIdentifier("smart.back")
                    }
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.sectionGap) {
                            if let error = viewModel.errorMessage {
                                Text(error).foregroundStyle(Theme.danger)
                                GhostButton(title: String(localized: .uiRetry)) { Task { await viewModel.retry() } }
                            }
                            if viewModel.stage == .setup {
                                SmartSetupView(viewModel: viewModel)
                            } else {
                                SmartConditionsView(viewModel: viewModel)
                            }
                        }.padding(Theme.horizontalPadding)
                    }.scrollIndicators(.hidden)
                        .safeAreaInset(edge: .bottom, spacing: Theme.space0) {
                            if viewModel.stage == .setup {
                                GlassActionButton(title: String(localized: .smartNext), action: { viewModel.showConditions() },
                                                  disabled: !viewModel.hasValidTargets || viewModel.isBusy)
                                    .accessibilityIdentifier("smart.continue").padding(Theme.cardInset)
                            } else {
                                GlassActionButton(title: String(localized: .smartPreview), action: { Task { await viewModel.preview() } },
                                                  disabled: viewModel.isBusy)
                                    .accessibilityIdentifier("smart.preview").padding(Theme.cardInset)
                            }
                        }
                }
                .disabled(viewModel.isBusy)
                .overlay { if viewModel.isBusy { ProgressView().tint(Theme.accent) } }
                .background {
                    if viewModel.stage == .conditions {
                        BackActionSwipeBridge(isEnabled: !viewModel.isBusy, onBack: requestBack).allowsHitTesting(false)
                    } else {
                        BackSwipeBridge {
                            guard !viewModel.isBusy else { return false }
                            if viewModel.hasUnsavedChanges { confirmDiscard = true; return false }
                            return true
                        }.allowsHitTesting(false)
                    }
                }
            }
        }
        .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text).tint(Theme.accent)
        .background(Theme.bg.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .alert(String(localized: .uiDiscardUnsavedChanges), isPresented: $confirmDiscard) {
            Button(String(localized: .uiDiscardChanges), role: .destructive) { dismiss() }
            Button(String(localized: .uiStay), role: .cancel) {}
        }
    }

    private func requestBack() {
        guard !viewModel.isBusy else { return }
        if viewModel.stage == .conditions { viewModel.goBack() } else if viewModel.hasUnsavedChanges {
            confirmDiscard = true
        } else { dismiss() }
    }
}

#if DEBUG
#Preview {
    SmartSelectionView(viewModel: SmartSelectionViewModel(workouts: PreviewWorkoutRepository(),
        exercises: PreviewExerciseRepository(), variants: PreviewSmartDailyVariantRepository(), targets: ["Chest"]),
        makeBuilder: { SessionBuilderViewModel(workouts: PreviewWorkoutRepository(), exercises: PreviewExerciseRepository(), smartContext: $0) },
        makeMovement: { MovementDetailViewModel(exercise: $0, allowsVideoLoading: false) }, onSaved: {}, onStart: { _ in })
        .preferredColorScheme(.dark)
}
#endif
