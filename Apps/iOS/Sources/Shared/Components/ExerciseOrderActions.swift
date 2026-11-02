import SwiftUI

/// Shared ordering and replacement controls for session drafts and saved workout drafts.
struct ExerciseOrderActions: View {
    let canMoveUp: Bool
    let canMoveDown: Bool
    var canReplace = true
    var identifierPrefix = "exerciseOrder"
    let onUp: () -> Void
    let onDown: () -> Void
    let onReplace: () -> Void

    var body: some View {
        HStack(spacing: Theme.space8) {
            Button(action: onUp) {
                OrderArrowIcon().frame(width: Theme.touchSize, height: Theme.touchSize)
            }.accessibilityLabel(String(localized: .uiWorkoutMoveUp)).disabled(!canMoveUp)
                .accessibilityIdentifier("\(identifierPrefix).up")
            Button(action: onDown) {
                OrderArrowIcon(pointsUp: false).frame(width: Theme.touchSize, height: Theme.touchSize)
            }.accessibilityLabel(String(localized: .uiWorkoutMoveDown)).disabled(!canMoveDown)
                .accessibilityIdentifier("\(identifierPrefix).down")
            Spacer(minLength: Theme.space0)
            Button(String(localized: .uiWorkoutReplace), action: onReplace)
                .font(Theme.fontSans(Theme.typeMeta, .semibold))
                .frame(minHeight: Theme.touchSize).disabled(!canReplace)
                .accessibilityIdentifier("\(identifierPrefix).replace")
        }
        .buttonStyle(PressableButtonStyle(animates: false))
        .foregroundStyle(Theme.text2)
    }
}
