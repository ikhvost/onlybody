import SwiftUI

struct BuilderMovementEditor: View {
    @Bindable var viewModel: SessionBuilderViewModel
    let movementID: UUID
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    @State private var path: [UUID] = []
    @Environment(\.dismiss) private var dismiss
    @State private var confirmRemoval = false
    let onCommit: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
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
                        Button(String(localized: .uiOpenExerciseGuide)) { path.append(movement.exercise.id) }
                            .frame(minHeight: Theme.touchSize).foregroundStyle(Theme.accent)
                            .accessibilityIdentifier("builder.movement.guide")
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
                GlassActionButton(title: String(localized: .uiDone), action: { onCommit(); dismiss() }, disabled: viewModel.hasInvalidNumbers)
                    .accessibilityIdentifier("builder.movement.done").padding(Theme.cardInset)
            }
            .alert(String(localized: .uiDesignRemoveQuestion), isPresented: $confirmRemoval) {
                Button(String(localized: .uiDesignRemoveExercise), role: .destructive) { onCommit(); viewModel.removeMovement(movementID); dismiss() }
                Button(String(localized: .uiCancel), role: .cancel) {}
            }
            .interactiveDismissDisabled(viewModel.hasInvalidNumbers)
            .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                if let exercise = viewModel.movements.first(where: { $0.id == movementID })?.exercise, exercise.id == id {
                    MovementDetailView(viewModel: makeMovement(exercise), backLabel: String(localized: .uiBack))
                }
            }
        }
    }
}
