import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutSnapshot
    let isToday: Bool
    let onEditTap: () -> Void
    let onStartTap: () -> Void
    var onOverviewTap: () -> Void = {}

    var body: some View {
        VStack(spacing: Theme.space16) {
            Button(action: onOverviewTap) {
                HStack(spacing: Theme.space12) {
                    VStack(alignment: .leading, spacing: Theme.space8) {
                        if workout.mode == WorkoutMode.smart.rawValue {
                            Text(.smartSmart).font(Theme.fontMono(Theme.typeMeta, .semibold)).foregroundStyle(Theme.accent)
                        }
                        Text(workout.name).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                        if let settings = workout.smartSettings {
                            Text(String(localized: .uiMinutesCount(settings.configuration.durationMinutes)) + " · " + settings.configuration.level.label)
                                .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                        } else {
                            Text(String(localized: .uiWorkoutSummary(
                                workout.scheduledDays.isEmpty ? String(localized: .uiUnscheduled)
                                    : workout.scheduledDays.map { CatalogLocalization.label($0) }.joined(separator: " · "), workout.items.count)))
                                .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                        }
                    }
                    Spacer(minLength: Theme.space0)
                    ChevronIcon(color: Theme.text2)
                }.frame(minHeight: Theme.touchSize).contentShape(.rect)
            }
            .buttonStyle(PressableButtonStyle(animates: false)).accessibilityIdentifier("workout.overview.\(workout.name)")
            HStack(spacing: Theme.space12) {
                GhostButton(title: String(localized: .uiDesignEdit), action: onEditTap)
                    .accessibilityLabel(String(localized: .uiEditWorkout(workout.name)))
                    .accessibilityIdentifier("workout.edit.\(workout.name)")
                PrimaryButton(title: String(localized: .uiDesignStart), action: onStartTap,
                              disabled: workout.items.isEmpty && workout.mode != WorkoutMode.smart.rawValue)
                    .accessibilityLabel(String(localized: .uiStartWorkout(workout.name)))
                    .accessibilityIdentifier("workout.start.\(workout.name)")
            }
        }
        .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay { RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(isToday ? Theme.accent : Theme.border2) }
    }
}
