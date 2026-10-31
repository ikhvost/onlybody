import SwiftUI

struct TrainEmptyState: View {
    var onCreate: () -> Void = {}

    var body: some View {
        VStack(spacing: Theme.space10) {
            MonoLabel(text: String(localized: .uiNoWorkoutsYet), size: Theme.typeMeta, color: Theme.text2, tracking: 1.0)
            PrimaryButton(title: String(localized: .uiCreateWorkout), action: onCreate)
                .accessibilityIdentifier("workout.create.empty")
            Text(.uiTapTheButtonToCreateAWorkout)
                .font(Theme.fontSans(Theme.typeMeta))
                .foregroundStyle(Theme.text3)
        }.padding(Theme.horizontalPadding)
    }
}
