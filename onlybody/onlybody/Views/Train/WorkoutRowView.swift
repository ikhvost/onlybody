import SwiftUI

struct WorkoutRowView: View {
    let workout: Workout
    let isToday: Bool
    let onEditTap: () -> Void
    let onStartTap: () -> Void

    private var daysText: String {
        if workout.scheduledDays.isEmpty {
            return "UNSCHEDULED"
        }
        return workout.scheduledDays.joined(separator: " · ")
    }

    private var movementCount: Int {
        workout.items?.count ?? 0
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: Theme.space3) {
                Text(workout.name)
                    .font(Theme.fontSans(15, .bold))
                    .foregroundStyle(Theme.text)

                MonoLabel(
                    text: "\(daysText)  ·  \(movementCount) MVMTS",
                    size: 9,
                    color: Theme.text3,
                    tracking: 0.5
                )
            }

            Spacer()

            Button {
                onEditTap()
            } label: {
                EditIcon(color: Theme.text3, size: 15)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(workout.name)")
            .padding(6)

            Button {
                onStartTap()
            } label: {
                Text("START ")
                    .tracking(1.2)
                    .font(Theme.fontMono(11, .medium))
                    .foregroundStyle(Theme.accentDark)
                    + Text("→")
                    .font(Theme.fontMono(11, .medium))
                    .foregroundStyle(Theme.accentDark)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Theme.space14)
            .frame(height: 36)
            .background(Theme.accent)
            .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
        }
        .padding(.vertical, Theme.space13)
        .padding(.horizontal, Theme.horizontalPadding)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isToday ? Theme.accent : .clear)
                .frame(width: 2)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
                .padding(.leading, Theme.horizontalPadding)
        }
    }
}
