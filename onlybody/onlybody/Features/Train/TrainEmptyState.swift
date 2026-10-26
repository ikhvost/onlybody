import SwiftUI

struct TrainEmptyState: View {
    var body: some View {
        VStack(spacing: Theme.space10) {
            MonoLabel(text: String(localized: .uiNoWorkoutsYet), size: Theme.type11, color: Theme.text2, tracking: 1.0)
            Text(.uiTapTheButtonToCreateAWorkout)
                .font(Theme.fontSans(Theme.type14))
                .foregroundStyle(Theme.text3)
        }
    }
}
