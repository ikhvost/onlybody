import SwiftUI

struct DayStripView: View {
    let dayNames: [String]
    let todayIndex: Int
    let workouts: [Workout]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(dayNames.enumerated(), id: \.offset) { index, day in
                let isToday = index == todayIndex
                let hasWorkout = workouts.contains { $0.scheduledDays.contains(day) }

                VStack(spacing: 5) {
                    MonoLabel(
                        text: day,
                        size: 8,
                        color: isToday ? Theme.accent : Theme.text3,
                        tracking: 0.3
                    )

                    Rectangle()
                        .fill(hasWorkout ? (isToday ? Theme.accent : Theme.border2) : .clear)
                        .frame(width: 3, height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
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
