import SwiftUI

struct SmartReplacementView: View {
    @State var viewModel: SmartReplacementViewModel
    let onReplace: (ExerciseSnapshot, Bool) -> Void
    let onExclude: () async -> Bool
    @Environment(\.dismiss) private var dismiss
    @State private var confirmExclusion = false
    @State private var isSaving = false
    @State private var saveFailed = false

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: String(localized: .smartReplace)) {
                if viewModel.equipmentUnavailable == nil {
                    NavigationCloseButton { dismiss() }.accessibilityIdentifier("smartReplacement.close")
                } else {
                    NavigationBackButton(action: requestBack).accessibilityIdentifier("smartReplacement.back")
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionGap) {
                    if saveFailed { Text(.uiCouldNotSaveSession).foregroundStyle(Theme.danger) }
                    if viewModel.equipmentUnavailable == nil {
                        Text(.smartReason).font(Theme.fontSans(Theme.typeCard, .bold))
                        GhostButton(title: String(localized: .smartUnavailable)) { viewModel.equipmentUnavailable = true }
                        GhostButton(title: String(localized: .smartAnother)) { viewModel.equipmentUnavailable = false }
                            .accessibilityIdentifier("smartReplacement.another")
                    } else {
                        Text(.smartLocal).foregroundStyle(Theme.text2)
                        if viewModel.alternatives.isEmpty { Text(.smartNoAlternatives) }
                        ForEach(viewModel.alternatives) { exercise in
                            Button {
                                if viewModel.conflicts(exercise).isEmpty { onReplace(exercise, false); dismiss() } else { viewModel.pendingConflict = exercise }
                            } label: {
                                VStack(alignment: .leading, spacing: Theme.space8) {
                                    Text(exercise.displayName)
                                    if !viewModel.conflicts(exercise).isEmpty {
                                        Text(viewModel.conflicts(exercise).map(\.label).joined(separator: " · "))
                                            .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
                                    }
                                }.frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                            }
                        }
                        Toggle(String(localized: .smartConflicts), isOn: $viewModel.showsConflicts)
                    }
                    Button(String(localized: .smartPermanent), role: .destructive) { confirmExclusion = true }
                        .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                }.padding(Theme.horizontalPadding)
            }.scrollIndicators(.hidden)
        }.disabled(isSaving).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text).tint(Theme.accent).background(Theme.bg)
            .background(BackActionSwipeBridge(isEnabled: !isSaving && !confirmExclusion && viewModel.pendingConflict == nil,
                                              onBack: requestBack).allowsHitTesting(false))
            .interactiveDismissDisabled(isSaving)
            .alert(String(localized: .smartConflict), isPresented: Binding(
                get: { viewModel.pendingConflict != nil }, set: { if !$0 { viewModel.pendingConflict = nil } })) {
                Button(String(localized: .smartConfirmConflict)) {
                    if let exercise = viewModel.pendingConflict { onReplace(exercise, true); dismiss() }
                }
                Button(String(localized: .uiCancel), role: .cancel) {}
            } message: { Text(viewModel.conflictMessage) }
            .alert(String(localized: .smartPermanent), isPresented: $confirmExclusion) {
                Button(String(localized: .smartExclude), role: .destructive) {
                    Task {
                        isSaving = true
                        if await onExclude() { dismiss() } else { saveFailed = true }
                        isSaving = false
                    }
                }
                Button(String(localized: .uiCancel), role: .cancel) {}
            } message: { Text(.smartPermanentHint) }
    }

    private func requestBack() {
        guard !isSaving else { return }
        if viewModel.equipmentUnavailable != nil {
            viewModel.equipmentUnavailable = nil
            viewModel.showsConflicts = false
        } else { dismiss() }
    }

}
