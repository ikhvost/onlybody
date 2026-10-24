import SwiftUI

struct TabVisibility: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
            .animation(reduceMotion ? nil : .easeInOut(duration: Theme.tabTransitionDuration), value: isSelected)
    }
}
