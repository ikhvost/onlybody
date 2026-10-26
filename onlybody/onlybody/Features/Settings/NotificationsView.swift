import SwiftUI

struct NotificationsView: View {
    @State var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.space0) {
                NavBarView(title: String(localized: .uiNotifications)) {
                    Button { dismiss() } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                            .frame(width: Theme.space44, height: Theme.space44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: .uiBackToSettings))
                    .accessibilityIdentifier("notifications.back")
                } trailing: {
                    Color.clear.frame(width: Theme.space44, height: Theme.space44)
                        .accessibilityHidden(true)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space24) {
                        SettingsSection(title: String(localized: .uiTraining)) {
                            NotificationReminderControls(viewModel: viewModel)
                        }
                        Text(.uiOneReminderOnYourScheduledTrainingDaysEvenIfYou)
                            .font(Theme.fontSans(Theme.type12))
                            .foregroundStyle(Theme.text2)

                        if viewModel.isPermissionDenied {
                            Text(.uiNotificationsAreDisabledInIosSettingsTurnOnWorkoutReminders)
                                .font(Theme.fontSans(Theme.type12))
                                .foregroundStyle(Theme.text2)
                        }
                        if viewModel.hasNoScheduledDays {
                            Text(.uiAddTrainingDaysToAWorkoutToReceiveReminders)
                                .font(Theme.fontSans(Theme.type12))
                                .foregroundStyle(Theme.text2)
                                .accessibilityIdentifier("notifications.noDays")
                        }
                        if let message = viewModel.errorMessage {
                            VStack(alignment: .leading, spacing: Theme.space12) {
                                Text(message)
                                    .font(Theme.fontSans(Theme.type12))
                                    .foregroundStyle(Theme.danger)
                                Button(String(localized: .uiRetry)) { Task { await viewModel.retry() } }
                                    .font(Theme.fontSans(Theme.type14, .semibold))
                                    .foregroundStyle(Theme.accent)
                                    .accessibilityIdentifier("notifications.retry")
                            }
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.vertical, Theme.space28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await viewModel.load() } }
        }
    }
}

#if DEBUG
#Preview("Notifications") {
    let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true)
    let reminders = WorkoutReminderCoordinator(
        preferences: preferences,
        workouts: PreviewWorkoutRepository(workouts: [WorkoutSnapshot(scheduledDays: ["Mon", "Fri"])]),
        notifications: PreviewWorkoutNotificationClient()
    )
    NotificationsView(viewModel: NotificationsViewModel(preferences: preferences, reminders: reminders))
        .preferredColorScheme(.dark)
}
#endif
