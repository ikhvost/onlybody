import SwiftUI

struct BuilderMovementEditor: View {
    @Bindable var viewModel: SessionBuilderViewModel
    let movementID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var confirmRemoval = false

    var body: some View {
        ScrollView {
            if let movement = viewModel.movements.first(where: { $0.id == movementID }) {
                VStack(alignment: .leading, spacing: Theme.space16) {
                    Text(movement.exercise.displayName).font(Theme.fontSans(Theme.typeExercise, .bold))
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
            PrimaryButton(title: String(localized: .uiDone), action: { dismiss() }, disabled: viewModel.hasInvalidNumbers)
                .accessibilityIdentifier("builder.movement.done").padding(Theme.cardInset).background(Theme.bg)
        }
        .alert(String(localized: .uiDesignRemoveQuestion), isPresented: $confirmRemoval) {
            Button(String(localized: .uiDesignRemoveExercise), role: .destructive) { viewModel.removeMovement(movementID); dismiss() }
            Button(String(localized: .uiCancel), role: .cancel) {}
        }
        .interactiveDismissDisabled(viewModel.hasInvalidNumbers)
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }
}
