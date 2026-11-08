import SwiftUI

struct WorkoutActivityMark: View {
    var body: some View {
        Image(systemName: "figure.strengthtraining.traditional")
            .font(Theme.fontSans(Theme.type16, .semibold))
            .foregroundStyle(Theme.accent)
            .accessibilityLabel(Text(.uiActiveWorkout))
    }
}
