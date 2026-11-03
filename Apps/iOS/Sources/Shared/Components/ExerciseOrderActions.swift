import SwiftUI

/// Ordering and replacement actions kept behind a single, centered menu control.
struct ExerciseOrderActions: View {
    let canMoveUp: Bool
    let canMoveDown: Bool
    var canReplace = true
    var identifierPrefix = "exerciseOrder"
    var title = String(localized: .uiMovements)
    let onUp: () -> Void
    let onDown: () -> Void
    let onReplace: () -> Void
    @State private var showingActions = false
    @State private var pendingAction: (() -> Void)?

    var body: some View {
        Button { showingActions = true } label: {
            MoreIcon().frame(width: Theme.touchSize, height: Theme.touchSize)
                .background(Theme.surface2, in: .circle)
        }
        .accessibilityLabel(String(localized: .uiDesignOptions))
        .accessibilityIdentifier("\(identifierPrefix).menu")
        .sheet(isPresented: $showingActions, onDismiss: {
            let action = pendingAction
            pendingAction = nil
            action?()
        }, content: {
            VStack(alignment: .leading, spacing: Theme.space8) {
                HStack {
                    Text(title).font(Theme.fontSans(Theme.typeCard, .bold))
                    Spacer()
                    Button { showingActions = false } label: { CloseIcon().frame(width: Theme.touchSize, height: Theme.touchSize) }
                        .buttonStyle(NavigationControlStyle()).accessibilityLabel(String(localized: .uiCancel))
                        .accessibilityIdentifier("\(identifierPrefix).close")
                }
                Button { select(onReplace) } label: {
                    Text(.uiWorkoutReplace)
                        .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                        .contentShape(.rect)
                }
                    .disabled(!canReplace).accessibilityIdentifier("\(identifierPrefix).replace")
                Button { select(onUp) } label: {
                    Text(.uiWorkoutMoveUp)
                        .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                        .contentShape(.rect)
                }
                    .disabled(!canMoveUp).accessibilityIdentifier("\(identifierPrefix).up")
                Button { select(onDown) } label: {
                    Text(.uiWorkoutMoveDown)
                        .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                        .contentShape(.rect)
                }
                    .disabled(!canMoveDown).accessibilityIdentifier("\(identifierPrefix).down")
                if !canReplace {
                    Text(.uiWorkoutReplaceLocked).font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                }
            }
            .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text)
            .padding(Theme.horizontalPadding)
            .presentationDetents([.medium]).presentationDragIndicator(.visible)
            .presentationBackground(Theme.surface).preferredColorScheme(.dark)
        })
    }

    private func select(_ action: @escaping () -> Void) {
        pendingAction = action
        showingActions = false
    }
}
