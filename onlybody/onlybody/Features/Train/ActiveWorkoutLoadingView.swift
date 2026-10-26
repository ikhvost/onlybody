import SwiftUI

struct ActiveWorkoutLoadingView: View {
    var body: some View {
        VStack(spacing: Theme.space10) {
            ProgressView()
                .tint(Theme.accent)
            MonoLabel(text: String(localized: .uiPreparingWorkout), size: Theme.type11, color: Theme.text3, tracking: 1)
        }
    }
}
