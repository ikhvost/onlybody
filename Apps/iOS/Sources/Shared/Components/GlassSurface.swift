import SwiftUI

/// Navigation material with an opaque accessibility fallback.
struct GlassSurface<Surface: Shape>: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let shape: Surface

    func body(content: Content) -> some View {
        if reduceTransparency || Theme.previewReducesMaterials {
            content.background(Theme.surface2, in: shape)
        } else {
            content.glassEffect(.regular.tint(Theme.glassTint).interactive(), in: shape)
        }
    }
}
