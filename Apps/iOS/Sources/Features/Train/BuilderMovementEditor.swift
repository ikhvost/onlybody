import SwiftUI

struct BuilderMovementEditor: View {
    @Bindable var viewModel: SessionBuilderViewModel
    let movementID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var confirmRemoval = false
    @State private var original: MovementConfig?
    @State private var committed = false

    var body: some View {
        ScrollView {
            if let movement = viewModel.movements.first(where: { $0.id == movementID }) {
                VStack(alignment: .leading, spacing: Theme.space16) {
                    HStack(alignment: .top) {
                        Text(movement.exercise.displayName).font(Theme.fontSans(Theme.typeExercise, .bold))
                        Spacer(minLength: Theme.space8)
                        Button { dismiss() } label: { CloseIcon().frame(width: Theme.touchSize, height: Theme.touchSize) }
                            .buttonStyle(.glass).buttonBorderShape(.circle).accessibilityLabel(String(localized: .uiCancel))
                            .accessibilityIdentifier("builder.movement.cancel")
                    }
                    ForEach(["Sets", "Reps", "Rest"], id: \.self) { field in
                        BuilderMovementNumber(viewModel: viewModel, movement: movement, field: field)
                    }
                    Button(String(localized: .uiDesignRemoveExercise), role: .destructive) { confirmRemoval = true }
                        .frame(minHeight: Theme.touchSize).foregroundStyle(Theme.danger)
                        .accessibilityIdentifier("builder.movement.remove")
                }.padding(Theme.horizontalPadding)
            }
        }
        .scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            GlassActionButton(title: String(localized: .uiDone), action: { committed = true; dismiss() }, disabled: viewModel.hasInvalidNumbers)
                .accessibilityIdentifier("builder.movement.done").padding(Theme.cardInset)
        }
        .alert(String(localized: .uiDesignRemoveQuestion), isPresented: $confirmRemoval) {
            Button(String(localized: .uiDesignRemoveExercise), role: .destructive) { committed = true; viewModel.removeMovement(movementID); dismiss() }
            Button(String(localized: .uiCancel), role: .cancel) {}
        }
        .interactiveDismissDisabled(viewModel.hasInvalidNumbers)
        .onAppear { if original == nil { original = viewModel.movements.first(where: { $0.id == movementID }) } }
        .onDisappear {
            if committed { viewModel.applySmartTimeBudget() } else if let original { viewModel.restoreMovement(original) }
        }
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }
}
