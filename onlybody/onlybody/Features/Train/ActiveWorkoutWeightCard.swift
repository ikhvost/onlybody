import SwiftUI

struct ActiveWorkoutWeightCard: View {
    let weight: Double
    let weightUnit: String
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        StepperView(
            label: String(localized: .uiAddedWeight(weightUnit)),
            identifier: "Added \(weightUnit)",
            valueText: weight.formatted(.number.precision(.fractionLength(0...2)).grouping(.never)),
            canDecrement: weight > 0,
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
