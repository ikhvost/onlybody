import SwiftUI

struct TrainEmptyStateView: View {
    var body: some View {
        VStack(spacing: Theme.space10) {
            MonoLabel(text: "No workouts yet", size: 10, color: Theme.text2, tracking: 1.0)
            Text("Tap the + button to create a workout")
                .font(Theme.fontSans(13))
                .foregroundStyle(Theme.text3)
        }
    }
}
