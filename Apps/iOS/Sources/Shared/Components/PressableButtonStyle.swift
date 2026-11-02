import SwiftUI

/// Keeps the interactive label at the minimum touch size, including icon-only buttons.
struct PressableButtonStyle: ButtonStyle {
    var animates = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
            .contentShape(.rect)
            .scaleEffect(animates && !reduceMotion && configuration.isPressed ? 0.96 : 1)
            .opacity(animates && configuration.isPressed ? 0.8 : 1)
            .animation(animates && !reduceMotion ? .easeOut(duration: 0.1) : nil, value: configuration.isPressed)
    }
}
