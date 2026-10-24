import SwiftUI

struct ExerciseDifficultyFilter: View {
    @Binding var selection: ExerciseDifficulty?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Theme.space6) {
                ChipView(label: "All levels", isActive: selection == nil, isSmall: true) {
                    selection = nil
                }
                .accessibilityIdentifier("difficulty.all")
                ForEach(ExerciseDifficulty.ratedLevels, id: \.self) { level in
                    ChipView(label: level.label, isActive: selection == level, isSmall: true) {
                        selection = level
                    }
                    .accessibilityLabel("Filter difficulty: \(level.label)")
                    .accessibilityIdentifier("difficulty.\(level.rawValue)")
                }
            }
            .padding(.bottom, Theme.space2)
        }
        .scrollIndicators(.hidden)
    }
}
