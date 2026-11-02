import SwiftUI

/// Scrolls only while a lifted card is held near the viewport's top or bottom edge.
struct ExerciseReorderAutoScroll: ViewModifier {
    @Binding var location: CGPoint?
    @State private var position = ScrollPosition(y: 0)
    @State private var viewport = CGRect.zero
    @State private var metrics = ExerciseReorderScrollMetrics(offset: 0, maximumOffset: 0)

    func body(content: Content) -> some View {
        content
            .scrollPosition($position)
            .scrollDisabled(location != nil)
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { viewport = $0 }
            .onScrollGeometryChange(for: ExerciseReorderScrollMetrics.self) { geometry in
                ExerciseReorderScrollMetrics(
                    offset: geometry.contentOffset.y,
                    maximumOffset: max(0, geometry.contentSize.height - geometry.containerSize.height + geometry.contentInsets.bottom)
                )
            } action: { _, value in metrics = value }
            .task(id: location != nil) {
                while location != nil, !Task.isCancelled {
                    do { try await Task.sleep(for: .milliseconds(16)) } catch { return }
                    guard let location, viewport.height > 0 else { continue }
                    let edge = Theme.exerciseReorderScrollEdge
                    let top = max(0, min(1, (viewport.minY + edge - location.y) / edge))
                    let bottom = max(0, min(1, (location.y - viewport.maxY + edge) / edge))
                    let distance = (bottom - top) * Theme.exerciseReorderScrollStep
                    guard distance != 0 else { continue }
                    let destination = min(metrics.maximumOffset, max(0, metrics.offset + distance))
                    if destination != metrics.offset { position.scrollTo(y: destination) }
                }
            }
    }
}
