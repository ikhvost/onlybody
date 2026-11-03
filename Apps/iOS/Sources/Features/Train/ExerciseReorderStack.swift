import SwiftUI

/// Renders the original rows as slots while the lifted card follows the finger.
struct ExerciseReorderStack<Item: Identifiable, Content: View>: View where Item.ID == UUID {
    let items: [Item]
    let spacing: CGFloat
    let isEnabled: Bool
    @Binding var dragLocation: CGPoint?
    let onMove: (UUID, UUID) -> Void
    @ViewBuilder let content: (Item, ExerciseReorderHandle) -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drag = ExerciseReorderViewModel()

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(items.enumerated(), id: \.element.id) { index, item in
                let isLifted = drag.liftedID == item.id
                ZStack {
                    content(item, ExerciseReorderHandle(
                        position: index + 1,
                        onLift: { if isEnabled { drag.lift(item.id) } },
                        onDrag: { start, location in
                            guard isEnabled else { return }
                            drag.drag(item.id, start: start, location: location, order: items.map(\.id))
                            dragLocation = location
                        },
                        onEnd: finish,
                        onCancel: cancel,
                        onAdjust: { adjust(item.id, direction: $0) }
                    ))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.accent, lineWidth: Theme.exerciseLiftBorder)
                            .opacity(isLifted ? 1 : 0)
                    }
                    .scaleEffect(isLifted && !reduceMotion ? Theme.exerciseLiftScale : 1)
                    .shadow(color: isLifted ? Theme.exerciseLiftShadow : .clear,
                            radius: Theme.exerciseLiftShadowRadius, y: Theme.exerciseLiftShadowOffset)
                    .animation(reduceMotion ? nil : .smooth(duration: Theme.exerciseLiftDuration), value: isLifted)
                    .offset(y: drag.offset(for: item.id, order: items.map(\.id), spacing: spacing))
                    .animation(isLifted || reduceMotion ? nil : .smooth(duration: Theme.exerciseReorderDuration), value: drag.targetID)
                }
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                    drag.updateFrame(frame, for: item.id, order: items.map(\.id))
                }
                .zIndex(isLifted ? 1 : 0)
            }
        }
        .animation(reduceMotion ? nil : .smooth(duration: Theme.exerciseReorderDuration), value: items.map(\.id))
        .sensoryFeedback(.selection, trigger: drag.targetID)
        .onChange(of: isEnabled) { _, enabled in if !enabled { cancel() } }
        .onChange(of: items.map(\.id)) { _, _ in cancel() }
        .onDisappear(perform: cancel)
    }

    private func adjust(_ id: UUID, direction: AccessibilityAdjustmentDirection) {
        guard isEnabled, let index = items.firstIndex(where: { $0.id == id }) else { return }
        switch direction {
        case .increment:
            if index + 1 < items.count { onMove(id, items[index + 1].id) }
        case .decrement:
            if index > 0 { onMove(id, items[index - 1].id) }
        @unknown default:
            break
        }
    }

    private func finish() {
        withAnimation(reduceMotion ? nil : .smooth(duration: Theme.exerciseReorderDuration)) {
            let move = drag.finish()
            dragLocation = nil
            if let move { onMove(move.source, move.target) }
        }
    }

    private func cancel() {
        withAnimation(reduceMotion ? nil : .smooth(duration: Theme.exerciseReorderDuration)) {
            drag.cancel()
            dragLocation = nil
        }
    }
}
