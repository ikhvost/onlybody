import SwiftUI

struct WorkoutList: View {
    let workouts: [WorkoutSnapshot]
    let todayName: String
    let onEdit: (WorkoutSnapshot) -> Void
    let onStart: (WorkoutSnapshot) -> Void
    var onOverview: (WorkoutSnapshot) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionGap) {
                Text(.uiToday).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                if !workouts.contains(where: { $0.scheduledDays.contains(todayName) }) {
                    Text(.uiDesignRestDay).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text2)
                }
                ForEach(workouts.filter { $0.scheduledDays.contains(todayName) }) { workout in
                    WorkoutRow(workout: workout, isToday: true, onEditTap: { onEdit(workout) },
                               onStartTap: { onStart(workout) }, onOverviewTap: { onOverview(workout) })
                }
                if workouts.contains(where: { !$0.scheduledDays.contains(todayName) }) {
                    Text(.uiDesignOtherWorkouts).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                    ForEach(workouts.filter { !$0.scheduledDays.contains(todayName) }) { workout in
                        WorkoutRow(workout: workout, isToday: false, onEditTap: { onEdit(workout) },
                                   onStartTap: { onStart(workout) }, onOverviewTap: { onOverview(workout) })
                    }
                }
            }.padding(Theme.horizontalPadding)
        }.scrollIndicators(.hidden)
    }
}
