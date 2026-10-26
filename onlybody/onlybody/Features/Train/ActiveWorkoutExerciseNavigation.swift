import SwiftUI

struct ActiveWorkoutExerciseNavigation: View {
    let canGoPrevious: Bool
    let canSkip: Bool
    let onPrevious: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: Theme.space8) {
            if canGoPrevious {
                GhostButton(title: String(localized: .uiPrev)) {
                    onPrevious()
                }
                .frame(maxWidth: .infinity)
            }

            if canSkip {
                GhostButton(title: String(localized: .uiSkip)) {
                    onSkip()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
