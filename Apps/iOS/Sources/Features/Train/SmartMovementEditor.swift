import SwiftUI

struct SmartMovementEditor: View {
    @State var viewModel: SmartMovementEditorViewModel
    let onSave: (WorkoutItemSnapshot) async -> Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.space16) {
                HStack(alignment: .top) {
                    Text(viewModel.name).font(Theme.fontSans(Theme.typeExercise, .bold))
                    Spacer(minLength: Theme.space8)
                    Button { dismiss() } label: { CloseIcon().frame(width: Theme.touchSize, height: Theme.touchSize) }
                        .buttonStyle(.glass).buttonBorderShape(.circle).accessibilityLabel(String(localized: .uiCancel))
                        .accessibilityIdentifier("smart.movement.cancel")
                }
                Text(.smartLocal).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                if viewModel.saveFailed { Text(.uiCouldNotSaveSession).foregroundStyle(Theme.danger) }
                ForEach(["Sets", "Reps", "Rest"], id: \.self) { field in
                    WorkoutNumberInput(title: viewModel.title(field), identifier: field,
                                       text: Binding(get: { viewModel.text(field) }, set: { viewModel.enter($0, field: field) }),
                                       hasError: viewModel.hasError(field), canDecrease: viewModel.canDecrease(field),
                                       onDecrease: { viewModel.step(field, increasing: false) },
                                       onIncrease: { viewModel.step(field, increasing: true) })
                }
            }.padding(Theme.horizontalPadding)
        }
        .scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            GlassActionButton(title: String(localized: .uiDone), action: commit,
                              disabled: viewModel.hasInvalidNumbers || viewModel.isSaving)
                .accessibilityIdentifier("smart.movement.done").padding(Theme.cardInset)
        }
        .disabled(viewModel.isSaving)
        .interactiveDismissDisabled(viewModel.isSaving || viewModel.hasInvalidNumbers)
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }

    private func commit() {
        Task {
            viewModel.isSaving = true
            let saved = await onSave(viewModel.item)
            viewModel.isSaving = false
            if saved { dismiss() } else { viewModel.saveFailed = true }
        }
    }
}
