import SwiftUI

struct ActiveWorkoutSetActions: View {
    let viewModel: ActiveWorkoutViewModel
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: Theme.space12) {
            GhostButton(title: String(localized: .uiRemove), action: onRemove)
                .accessibilityLabel(String(localized: .uiRemoveLastSet))
                .accessibilityIdentifier("active.set.removeLast")
                .disabled(!viewModel.canRemoveLastSet)
                .opacity(viewModel.canRemoveLastSet ? 1 : Theme.disabledControlOpacity)
            Spacer(minLength: Theme.space12)
            GhostButton(title: String(localized: .uiAdd), action: onAdd)
                .accessibilityLabel(String(localized: .uiAddSet))
                .accessibilityIdentifier("active.set.add")
                .disabled(!viewModel.canAddSet)
                .opacity(viewModel.canAddSet ? 1 : Theme.disabledControlOpacity)
        }
    }
}
