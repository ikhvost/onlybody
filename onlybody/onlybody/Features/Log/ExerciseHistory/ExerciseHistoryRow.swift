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
                    if let weight = item.weightKg {
                        Text("\(weight.formatted(.number.precision(.fractionLength(0...2)))) kg added")
                            .foregroundStyle(Theme.accent)
                            .accessibilityIdentifier("exerciseHistory.weight")
                    } else {
                        Text("Added weight not recorded")
                            .foregroundStyle(Theme.text2)
                    }
                    ForEach(item.setReps.indices, id: \.self) { index in
                        HStack {
                            Text("Set \(index + 1)")
                                .foregroundStyle(Theme.text2)
                            Spacer()
                            Text("\(item.setReps[index]) reps")
                                .foregroundStyle(Theme.text)
                        }
                        .accessibilityElement(children: .combine)
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
