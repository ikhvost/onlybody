import ActivityKit
import SwiftUI
import WidgetKit

@main
struct WorkoutActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            WorkoutActivityCard(workoutName: context.attributes.workoutName, state: context.state)
                .padding(Theme.cardInset)
                .activityBackgroundTint(Theme.bg)
                .activitySystemActionForegroundColor(Theme.text)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    WorkoutActivityCard(workoutName: context.attributes.workoutName, state: context.state)
                }
            } compactLeading: {
                WorkoutActivityMark()
            } compactTrailing: {
                WorkoutActivityCountdown(state: context.state, size: Theme.type14, width: Theme.space48)
            } minimal: {
                if context.state.restDeadline != nil {
                    WorkoutActivityCountdown(state: context.state, size: Theme.type11, width: Theme.space36)
                } else {
                    WorkoutActivityMark()
                }
            }
            .keylineTint(Theme.accent)
        }
    }
}
