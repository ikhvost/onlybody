import SwiftUI

struct SettingsYouTubeConsentView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            Text(viewModel.areYouTubeVideosAllowed ? "YouTube videos allowed" : "YouTube videos off")
                .font(Theme.fontSans(Theme.type14, .medium))
                .foregroundStyle(Theme.text)
            Text(
                "Google processes technical data and video activity for playback, security, measurement and non-personalized "
                    + "ads. Turning videos off stops embedded YouTube connections; it does not delete data already received by Google."
            )
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
            if viewModel.areYouTubeVideosAllowed {
                Button("Withdraw YouTube permission", action: viewModel.revokeYouTubeConsent)
                    .font(Theme.fontSans(Theme.type14, .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(minHeight: Theme.space44)
                    .accessibilityIdentifier("settings.revokeYouTube")
            } else {
                Text("You can allow videos again from any exercise with a demonstration.")
                    .font(Theme.fontSans(Theme.type12))
                    .foregroundStyle(Theme.text2)
            }
        }
        .padding(Theme.space16)
        .accessibilityIdentifier("settings.youtubeConsent")
    }
}
