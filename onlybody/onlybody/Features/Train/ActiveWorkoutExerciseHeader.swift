import SwiftUI

struct ActiveWorkoutExerciseHeader: View {
    let exerciseName: String
    let setLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space4) {
            Text(exerciseName)
                .font(Theme.fontSans(Theme.type38, .heavy))
                .tracking(-1.5)
                .foregroundStyle(Theme.text)
                .lineSpacing(0)

            MonoLabel(
                text: setLabel,
                size: Theme.type11,
                color: Theme.text3,
                tracking: 0.8
            )
            .padding(.top, Theme.space22)
        }
    }
}
