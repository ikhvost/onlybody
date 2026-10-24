import SwiftUI

struct TrainDayStrip: View {
    let dayNames: [String]
    let todayIndex: Int
    let workouts: [WorkoutSnapshot]

    var body: some View {
        HStack(spacing: Theme.space4) {
            ForEach(dayNames.enumerated(), id: \.offset) { index, day in
                let isToday = index == todayIndex
                let hasWorkout = workouts.contains { $0.scheduledDays.contains(day) }

                VStack(spacing: Theme.space5) {
                    MonoLabel(
                        text: day,
                        size: Theme.type10,
                        color: isToday ? Theme.accent : Theme.text3,
                        tracking: 0.3
                    )

                    Rectangle()
                        .fill(hasWorkout ? (isToday ? Theme.accent : Theme.border2) : .clear)
                        .frame(width: 3, height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.space5)
                .overlay(alignment: .bottom) {
                    if isToday {
                        Rectangle()
                            .fill(Theme.accent)
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.bottom, Theme.space10)
    }
}
