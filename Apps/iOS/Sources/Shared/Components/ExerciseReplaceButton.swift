import SwiftUI

/// Opens exercise replacement directly, without an intermediate actions sheet.
struct ExerciseReplaceButton: View {
    var canReplace = true
    let identifier: String
    let onReplace: () -> Void

    var body: some View {
        Button(action: onReplace) {
            Label {
                Text(.uiWorkoutReplace)
            } icon: {
                ReplaceIcon(color: canReplace ? Theme.text : Theme.iconDim)
            }
            .labelStyle(.iconOnly)
            .frame(width: Theme.touchSize, height: Theme.touchSize)
            .background(Theme.surface2, in: .circle)
        }
        .buttonStyle(PressableButtonStyle(animates: false))
        .disabled(!canReplace)
        .accessibilityIdentifier(identifier)
        .accessibilityHint(canReplace ? "" : String(localized: .uiWorkoutReplaceLocked))
    }
}
