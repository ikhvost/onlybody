import SwiftUI

struct WorkoutActivityCard: View {
    let workoutName: String
    let state: WorkoutActivityState

    var body: some View {
        HStack(alignment: .center, spacing: Theme.space12) {
            VStack(alignment: .leading, spacing: Theme.space4) {
                Text(verbatim: workoutName)
                    .font(Theme.fontSans(Theme.typeBody, .semibold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                if state.allSetsCompleted {
                    Text(.uiAllSetsCompleted)
                        .font(Theme.fontSans(Theme.typeMeta))
                        .foregroundStyle(Theme.text2)
                } else {
                    if let name = state.exerciseName {
                        Text(verbatim: name)
                            .font(Theme.fontSans(Theme.typeMeta, .medium))
                            .foregroundStyle(Theme.text2)
                            .lineLimit(2)
                    }
                    if let set = state.setNumber, let total = state.totalSets {
                        Text(.uiSetProgress(set, total))
                            .font(Theme.fontSans(Theme.typeMeta))
                            .foregroundStyle(Theme.text2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)

            if state.restDeadline != nil {
                VStack(alignment: .trailing, spacing: Theme.space4) {
                    Text(.uiRest)
                        .font(Theme.fontSans(Theme.typeMeta))
                        .foregroundStyle(Theme.text2)
                    WorkoutActivityCountdown(state: state, size: Theme.type28, width: Theme.activityCountdownWidth)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
