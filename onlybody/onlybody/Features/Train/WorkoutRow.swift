import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutSnapshot
    let isToday: Bool
    let onEditTap: () -> Void
    let onStartTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.space14) {
            VStack(alignment: .leading, spacing: Theme.space3) {
                Text(workout.name)
                    .font(Theme.fontSans(Theme.type16, .bold))
                    .foregroundStyle(Theme.text)

                MonoLabel(
                    text: String(localized: .uiWorkoutSummary(
                        workout.scheduledDays.isEmpty ? String(localized: .uiUnscheduled)
                            : workout.scheduledDays.map { CatalogLocalization.label($0) }.joined(separator: " · "),
                        workout.items.count)),
                    size: Theme.type9,
                    color: Theme.text3,
                    tracking: 0.5
                )
            }

            Spacer()

            Button {
                onEditTap()
            } label: {
                EditIcon(color: Theme.text3, size: Theme.type15)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel(String(localized: .uiEditWorkout(workout.name)))
            .accessibilityIdentifier("workout.edit.\(workout.name)")
            .padding(Theme.space6)

            Button {
                onStartTap()
            } label: {
                Text(.uiStartUppercase)
                    .tracking(1.2)
                    .font(Theme.fontMono(Theme.type12, .medium))
                    .foregroundStyle(Theme.accentDark)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel(String(localized: .uiStartWorkout(workout.name)))
            .accessibilityIdentifier("workout.start.\(workout.name)")
            .padding(.horizontal, Theme.space14)
            .frame(height: 40)
            .background(Theme.accent)
            .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
        }
        .padding(.vertical, Theme.space16)
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
