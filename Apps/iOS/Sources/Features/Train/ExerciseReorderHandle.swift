import SwiftUI

struct ExerciseReorderHandle: View {
    let position: Int
    let onLift: () -> Void
    let onDrag: (CGPoint, CGPoint) -> Void
    let onEnd: () -> Void
    let onCancel: () -> Void
    let onAdjust: (AccessibilityAdjustmentDirection) -> Void
    @GestureState private var isTouching = false

    var body: some View {
        ReorderIcon()
            .frame(width: Theme.touchSize, height: Theme.touchSize)
            .contentShape(.rect)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: .uiWorkoutReorder))
            .accessibilityValue(Text(position, format: .number))
            .accessibilityAdjustableAction(onAdjust)
            .gesture(
                LongPressGesture(minimumDuration: Theme.exerciseLiftDelay)
                    .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                    .updating($isTouching) { _, touching, _ in touching = true }
                    .onChanged { value in
                        guard case .second(true, let drag) = value else { return }
                        onLift()
                        if let drag { onDrag(drag.startLocation, drag.location) }
                    }
                    .onEnded { _ in onEnd() }
            )
            .onChange(of: isTouching) { _, touching in
                if !touching { onCancel() }
            }
    }
}
