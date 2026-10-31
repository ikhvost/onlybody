import SwiftUI

/// Local-only placeholder: no remote thumbnail, script or player is loaded before permission.
struct YouTubeConsentView: View {
    let canRequestPermission: Bool
    let isRequestingPermission: Bool
    let onAllow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            Text(.uiWatchExerciseVideos)
                .font(Theme.fontSans(Theme.type15, .semibold))
                .foregroundStyle(Theme.text)
            Text(canRequestPermission ? String(localized: .uiYoutubeTrackingExplanation) : String(localized: .uiYoutubeExternalPlayback))
                .font(Theme.fontSans(Theme.type13))
                .foregroundStyle(Theme.text2)
            Text(.uiYouCanTurnVideosOffInSettings)
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
            Text(.uiGooglePrivacyPolicyHttpsPoliciesGoogleComPrivacyYoutubeTerms)
                .font(Theme.fontSans(Theme.type12))
                .tint(Theme.accent)
            if canRequestPermission {
                Button(String(localized: .uiContinueToVideoPermission), action: onAllow)
                    .font(Theme.fontSans(Theme.type15, .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(minHeight: Theme.space44)
                    .disabled(isRequestingPermission)
                    .accessibilityIdentifier("demonstration.allowYouTube")
            }
        }
        .padding(Theme.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .accessibilityIdentifier("demonstration.consent")
    }
}
