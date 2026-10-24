import SwiftUI

struct ExerciseHistoryRow: View {
    let entry: ExerciseHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            VStack(alignment: .leading, spacing: Theme.space4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.fontSans(Theme.type15, .bold))
                    .foregroundStyle(Theme.text)
                    .accessibilityIdentifier("exerciseHistory.date")
                Text(entry.workoutName)
                    .font(Theme.fontSans(Theme.type13))
                    .foregroundStyle(Theme.text2)
            }
            ForEach(entry.items) { item in
                VStack(alignment: .leading, spacing: Theme.space8) {
                    ForEach(item.setReps.indices, id: \.self) { index in
                        HStack {
                            Text("Set \(index + 1)")
                                .foregroundStyle(Theme.text2)
                            Spacer()
                            Text("\(item.setReps[index]) reps")
                                .foregroundStyle(Theme.text)
                            if let weight = item.weightForSet(at: index) {
                                Text("· \(weight.formatted(.number.precision(.fractionLength(0...2)))) kg")
                                    .foregroundStyle(Theme.accent)
                            } else {
                                Text("· weight not recorded")
                                    .foregroundStyle(Theme.text2)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("exerciseHistory.set.\(index)")
                    }
                }
                .font(Theme.fontMono(Theme.type12))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.space16)
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
