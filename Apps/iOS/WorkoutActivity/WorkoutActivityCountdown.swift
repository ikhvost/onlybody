import SwiftUI

struct WorkoutActivityCountdown: View {
    let state: WorkoutActivityState
    let size: CGFloat
    let width: CGFloat

    var body: some View {
        if let start = state.restStartedAt, let deadline = state.restDeadline, start < deadline {
            Text(timerInterval: start...deadline, countsDown: true, showsHours: false)
                .font(Theme.fontMono(size, .semibold))
                .foregroundStyle(Theme.accent)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(Theme.activityCountdownMinimumScale)
                .frame(width: width, alignment: .trailing)
        }
    }
}
