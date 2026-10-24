import SwiftUI

struct WorkoutList: View {
    let workouts: [WorkoutSnapshot]
    let todayName: String
    let onEdit: (WorkoutSnapshot) -> Void
    let onStart: (WorkoutSnapshot) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.space0) {
                ForEach(workouts) { workout in
                    WorkoutRow(
                        workout: workout,
                        isToday: workout.scheduledDays.contains(todayName),
                        onEditTap: { onEdit(workout) },
                        onStartTap: { onStart(workout) }
                    )
                }
            }
            .padding(.bottom, Theme.space16)
        }
        .scrollIndicators(.hidden)
    }
}
