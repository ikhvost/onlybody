import SwiftUI

struct TrainHeader: View {
    let appName: String
    let dateDisplay: String
    let onSettingsTap: () -> Void
    let onCreateTap: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.space8) {
            VStack(alignment: .leading, spacing: Theme.space3) {
                MonoLabel(text: dateDisplay, size: Theme.type10, color: Theme.text3, tracking: 1.2)
                Text(appName)
                    .font(Theme.fontSans(Theme.type28, .heavy))
                    .tracking(-1)
                    .foregroundStyle(Theme.text)
            }

            Spacer()

            Button(action: onSettingsTap) {
                SettingsIcon(color: Theme.text2, size: Theme.type20)
                    .frame(width: Theme.space44, height: Theme.space44)
                    .contentShape(.rect)
            }
            .accessibilityLabel(String(localized: .uiSettings))
            .accessibilityIdentifier("train.settings")
            .buttonStyle(PressableButtonStyle())

            Button {
                onCreateTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.accent)
                        .frame(width: Theme.headerActionSize, height: Theme.headerActionSize)

                    PlusIcon(color: Theme.accentDark, size: Theme.type15)
                }
                .frame(width: Theme.space44, height: Theme.space44)
                .contentShape(.rect)
            }
            .accessibilityLabel(String(localized: .uiCreateWorkout))
            .accessibilityIdentifier("workout.create")
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space16)
        .padding(.bottom, Theme.space10)
    }
}
