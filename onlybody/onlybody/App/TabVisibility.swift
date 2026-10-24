import SwiftUI

struct TabVisibility: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
