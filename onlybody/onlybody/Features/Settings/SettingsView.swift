import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    let onNotifications: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: String(localized: .uiSettings)) {
                    Button {
                        dismiss()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                            .frame(width: Theme.space44, height: Theme.space44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: .uiBackToTraining))
                    .accessibilityIdentifier("settings.back")
                } trailing: {
                    Color.clear
                        .frame(width: Theme.space44, height: Theme.space44)
                        .accessibilityHidden(true)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space28) {
                        SettingsSection(title: String(localized: .uiTraining)) {
                            SettingsSoundToggle(isEnabled: $viewModel.isTimerSoundEnabled)
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsNotificationsLink(action: onNotifications)
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsWeightUnitPicker(viewModel: viewModel)
                        }

                        SettingsSection(title: "YouTube") {
                            SettingsYouTubeConsentView(viewModel: viewModel)
                        }

                        SettingsSection(title: String(localized: .uiSupport)) {
                            SettingsRow(
                                title: String(localized: .uiSendFeedback),
                                identifier: "settings.feedback",
                                destination: viewModel.feedbackURL,
                                destinationDescription: String(localized: .uiOpensEmailApp)
                            )
                        }

                        SettingsSection(title: String(localized: .uiLegal)) {
                            SettingsRow(
                                title: String(localized: .uiPrivacyPolicy),
                                identifier: "settings.privacy",
                                destination: viewModel.privacyPolicyURL
                            )
                            Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness)
                            SettingsRow(
                                title: String(localized: .uiTermsOfUse),
                                identifier: "settings.terms",
                                destination: viewModel.termsOfUseURL
                            )
                        }

                        VStack(spacing: Theme.space6) {
                            Text(viewModel.appName)
                                .font(Theme.fontSans(Theme.type14, .bold))
                                .foregroundStyle(Theme.text2)
                            Text(String(localized: .uiVersion(viewModel.version)))
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
