import SwiftUI

struct BuilderMovementCard: View {
    let viewModel: SessionBuilderViewModel
    let movement: MovementConfig
    @State private var showingEditor = false

    var body: some View {
        Button { showingEditor = true } label: {
            HStack(spacing: Theme.space12) {
                VStack(alignment: .leading, spacing: Theme.space8) {
                    Text(movement.exercise.displayName).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                    Text(String(localized: .uiMovementSummary(movement.sets, movement.reps, movement.restSeconds)))
                        .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                }
                Spacer(minLength: Theme.space0)
                ChevronIcon(color: Theme.text2)
            }
            .frame(minHeight: Theme.touchSize).padding(Theme.cardInset)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(PressableButtonStyle(animates: false)).accessibilityIdentifier("builder.movement.\(movement.id)")
        .sheet(isPresented: $showingEditor) {
            BuilderMovementEditor(viewModel: viewModel, movementID: movement.id)
                .presentationDetents([.large]).presentationDragIndicator(.visible)
        }
    }
}
