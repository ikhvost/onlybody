import SwiftUI

/// A compact glass control; text remains available to accessibility.
struct NavigationControlStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
            .modifier(GlassSurface(shape: Circle()))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
