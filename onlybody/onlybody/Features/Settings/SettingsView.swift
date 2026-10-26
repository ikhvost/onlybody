import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    let onNotifications: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: "Settings") {
                    Button {
                        dismiss()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                            .frame(width: Theme.space44, height: Theme.space44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to training")
                    .accessibilityIdentifier("settings.back")
                } trailing: {
                    Color.clear
                        .frame(width: Theme.space44, height: Theme.space44)
                        .accessibilityHidden(true)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space28) {
                        SettingsSection(title: "Training") {
                            SettingsSoundToggle(isEnabled: $viewModel.isTimerSoundEnabled)
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsNotificationsLink(action: onNotifications)
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsWeightUnitPicker(viewModel: viewModel)
                        }

                        SettingsSection(title: "Support") {
                            SettingsRow(
                                title: "Send feedback",
                                identifier: "settings.feedback",
                                destination: viewModel.feedbackURL,
                                destinationDescription: "Opens email app"
                            )
                        }

                        SettingsSection(title: "Legal") {
                            SettingsRow(
                                title: "Privacy Policy",
                                identifier: "settings.privacy",
                                destination: viewModel.privacyPolicyURL
                            )
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsRow(
                                title: "Terms of Use",
                                identifier: "settings.terms",
                                destination: viewModel.termsOfUseURL
                            )
                        }

                        VStack(spacing: Theme.space6) {
                            Text(viewModel.appName)
                                .font(Theme.fontSans(Theme.type14, .bold))
                                .foregroundStyle(Theme.text2)
                            Text("Version \(viewModel.version)")
                                .font(Theme.fontMono(Theme.type10))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Theme.space16)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("settings.version")
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.vertical, Theme.space28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview("Settings — OnlyBody") {
    SettingsView(viewModel: SettingsViewModel(appName: "OnlyBody", version: "1.0"), onNotifications: {})
        .preferredColorScheme(.dark)
}

#Preview("Settings — OnlyWeights") {
    SettingsView(viewModel: SettingsViewModel(appName: "OnlyWeights", version: "1.0"), onNotifications: {})
        .preferredColorScheme(.dark)
}
#endif
