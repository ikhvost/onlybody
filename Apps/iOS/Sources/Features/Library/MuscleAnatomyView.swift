import SwiftUI

/// One generated reference with deterministic, independently selectable muscle regions.
struct MuscleAnatomyView: View {
    let diagram: MuscleDiagram
    let image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .colorMultiply(Theme.muscleDiagramNeutral)
            .overlay {
                Canvas { context, size in
                    context.scaleBy(x: size.width / MuscleRegionPaths.viewport, y: size.height / MuscleRegionPaths.viewport)
                    for group in diagram.secondary {
                        context.fill(MuscleRegionPaths.path(for: group), with: .color(Theme.muscleDiagramSecondary))
                    }
                    for group in diagram.primary {
                        context.fill(MuscleRegionPaths.path(for: group), with: .color(Theme.accent))
                    }
                }
                .mask { image.resizable().scaledToFit() }
                .blendMode(.color)
                .accessibilityHidden(true)
            }
            .compositingGroup()
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}
