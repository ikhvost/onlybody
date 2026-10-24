import SwiftUI

struct ActiveWorkoutExerciseNavigation: View {
    let canGoPrevious: Bool
    let canSkip: Bool
    let onPrevious: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: Theme.space8) {
            if canGoPrevious {
                GhostButton(title: "\u{2190} Prev") {
                    onPrevious()
                }
                .frame(maxWidth: .infinity)
            }

            if canSkip {
                GhostButton(title: "Skip \u{2192}") {
                    onSkip()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
