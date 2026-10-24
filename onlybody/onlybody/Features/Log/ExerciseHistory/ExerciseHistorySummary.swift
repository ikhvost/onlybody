import SwiftUI

struct ExerciseHistorySummary: View {
    let workouts: Int
    let sets: Int
    let reps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: "All saved workouts", size: Theme.type10, color: Theme.text2)
            Text("\(reps) reps total")
                .font(Theme.fontSans(Theme.type24, .bold))
                .foregroundStyle(Theme.accent)
                .accessibilityIdentifier("exerciseHistory.totalReps")
            Text("Workouts: \(workouts) · Sets: \(sets)")
                .font(Theme.fontMono(Theme.type12))
                .foregroundStyle(Theme.text2)
                .accessibilityIdentifier("exerciseHistory.totals")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.space16)
        .background(Theme.accentDim)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
