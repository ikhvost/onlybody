import SwiftUI

struct ActiveWorkoutUpNextSection: View {
    let nextExerciseName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space2) {
            MonoLabel(text: "Up next", size: Theme.type10, color: Theme.text3, tracking: 0.5)
            Text(nextExerciseName)
                .font(Theme.fontSans(Theme.type14, .semibold))
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space8)
    }
}
