import SwiftUI

struct ActiveWorkoutStepperCards: View {
    let reps: Int
    let weight: Double
    let onIncrementReps: () -> Void
    let onDecrementReps: () -> Void
    let onIncrementWeight: () -> Void
    let onDecrementWeight: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Theme.space10) {
            ActiveWorkoutRepsCard(
                reps: reps,
                onIncrement: onIncrementReps,
                onDecrement: onDecrementReps
            )
            ActiveWorkoutWeightCard(
                weight: weight,
                onIncrement: onIncrementWeight,
                onDecrement: onDecrementWeight
            )
        }
    }
}
