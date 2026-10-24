import SwiftUI

struct ActiveWorkoutRepsCard: View {
    let reps: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        StepperView(
            label: "Reps",
            value: reps,
            step: 1,
            minValue: 0,
            format: { "\($0)" },
            onIncrement: onIncrement,
            onDecrement: onDecrement
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space12)
        .padding(.horizontal, Theme.space14)
        .background(Theme.surface)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
