import SwiftUI

struct NotificationReminderControls: View {
    @Bindable var viewModel: NotificationsViewModel

    var body: some View {
        VStack(spacing: Theme.space0) {
            Toggle(isOn: Binding(get: { viewModel.isEnabled }, set: { enabled in
                Task { await viewModel.setEnabled(enabled) }
            })) {
                Text(.uiWorkoutReminders)
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
            }
            .toggleStyle(.switch)
            .tint(Theme.accent)
            .frame(minHeight: Theme.space44)
            .padding(Theme.space16)
            .disabled(viewModel.isRequestingPermission)
            .accessibilityIdentifier("notifications.enabled")

            if viewModel.isEnabled {
                Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                VStack(alignment: .leading, spacing: Theme.space8) {
                    MonoLabel(text: String(localized: .uiReminderTime), size: Theme.type10, color: Theme.text2, tracking: 1)
                    Picker(String(localized: .uiReminderTime), selection: $viewModel.selectedTime) {
                        ForEach(viewModel.timeOptions, id: \.self) { time in
                            Text(time.label)
                                .font(Theme.fontMono(Theme.type20))
                                .tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: Theme.timingWheelHeight)
                    .accessibilityIdentifier("notifications.time")
                }
                .padding(Theme.space16)
            }
        }
    }
}
