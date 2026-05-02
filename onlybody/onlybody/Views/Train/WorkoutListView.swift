import SwiftUI

struct WorkoutListView: View {
    let workouts: [Workout]
    let todayName: String
    let onEdit: (Workout) -> Void
    let onStart: (Workout) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(workouts) { workout in
                    WorkoutRowView(
                        workout: workout,
                        isToday: workout.scheduledDays.contains(todayName),
                        onEditTap: { onEdit(workout) },
                        onStartTap: { onStart(workout) }
                    )
                }

                Rectangle()
                    .fill(.clear)
                    .frame(height: Theme.space16)
            }
        }
        .scrollIndicators(.hidden)
    }
}
