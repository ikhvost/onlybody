import SwiftUI

/// Local-only placeholder: no remote thumbnail, script or player is loaded before permission.
struct YouTubeConsentView: View {
    let onAllow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            Text("YouTube videos are off")
                .font(Theme.fontSans(Theme.type15, .semibold))
                .foregroundStyle(Theme.text)
            Text(
                "Allow Google to receive device information, your IP address and video activity, and use cookies or similar "
                    + "storage for playback, security, measurement and non-personalized ads. Your workouts stay on this device."
            )
                .font(Theme.fontSans(Theme.type13))
                .foregroundStyle(Theme.text2)
            Text("Your choice is saved for this app. You can withdraw it in Settings. You can keep training without allowing videos.")
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
            Text("[Google Privacy Policy](https://policies.google.com/privacy) · [YouTube Terms](https://www.youtube.com/t/terms)")
                .font(Theme.fontSans(Theme.type12))
                .tint(Theme.accent)
            Button("Allow YouTube videos", action: onAllow)
                .font(Theme.fontSans(Theme.type15, .semibold))
                .foregroundStyle(Theme.accent)
                .frame(minHeight: Theme.space44)
                .accessibilityIdentifier("demonstration.allowYouTube")
        }
        .padding(Theme.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .accessibilityIdentifier("demonstration.consent")
    }
}
