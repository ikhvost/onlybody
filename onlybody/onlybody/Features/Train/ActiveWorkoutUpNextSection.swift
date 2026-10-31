import SwiftUI

struct ActiveWorkoutUpNextSection: View {
    let nextExerciseName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space2) {
            MonoLabel(text: String(localized: .uiUpNext), size: Theme.typeMeta, color: Theme.text3, tracking: 0.5)
            Text(nextExerciseName)
                .font(Theme.fontSans(Theme.typeMeta, .semibold))
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space8)
    }
}
