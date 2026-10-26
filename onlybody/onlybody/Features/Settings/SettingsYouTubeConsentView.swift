import SwiftUI

struct SettingsYouTubeConsentView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            Text(viewModel.areYouTubeVideosAllowed ? String(localized: .uiYoutubeVideosAllowed) : String(localized: .uiYoutubeVideosOff))
                .font(Theme.fontSans(Theme.type14, .medium))
                .foregroundStyle(Theme.text)
            Text(
                String(localized: .uiGoogleProcessesTechnicalDataAndVideoActivityForPlaybackSecurity)
            )
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
            if viewModel.areYouTubeVideosAllowed {
                Button(String(localized: .uiWithdrawYoutubePermission), action: viewModel.revokeYouTubeConsent)
                    .font(Theme.fontSans(Theme.type14, .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(minHeight: Theme.space44)
                    .accessibilityIdentifier("settings.revokeYouTube")
            } else {
                Text(.uiYouCanAllowVideosAgainFromAnyExerciseWithA)
                    .font(Theme.fontSans(Theme.type12))
                    .foregroundStyle(Theme.text2)
            }
        }
        .padding(Theme.space16)
        .accessibilityIdentifier("settings.youtubeConsent")
    }
}
