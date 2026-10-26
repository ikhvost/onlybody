import SwiftUI

/// Static presentation also used by previews; never creates a web view or makes a request.
struct DemonstrationPlaceholderView: View {
    let state: DemonstrationPlaybackState
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Theme.space12) {
            if state == .offline {
                Text(.uiVideoUnavailableOffline)
                    .accessibilityIdentifier("demonstration.offline")
            } else if case .failed(let failure) = state {
                Text(failure.message)
                    .accessibilityIdentifier("demonstration.error")
                Button(String(localized: .uiRetry), action: onRetry)
                    .font(Theme.fontSans(Theme.type15, .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(minHeight: Theme.space44)
                    .accessibilityLabel(String(localized: .uiRetryLoadingDemonstration))
                    .accessibilityIdentifier("demonstration.retry")
            } else if state == .loading || state == .idle {
                ProgressView()
                    .tint(Theme.accent)
                    .accessibilityLabel(String(localized: .uiLoadingVideoMessageC189))
                Text(.uiLoadingVideo)
            } else {
                PlayIcon(color: Theme.accent, size: Theme.space48)
                    .accessibilityLabel(String(localized: .uiVideoPreview))
                    .accessibilityIdentifier("demonstration.preview")
            }
        }
        .font(Theme.fontSans(Theme.type14))
        .foregroundStyle(Theme.text2)
        .multilineTextAlignment(.center)
        .padding(.horizontal, Theme.space16)
        .frame(maxWidth: .infinity)
        .frame(height: Theme.demonstrationHeight)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
    }
}

#Preview("Demonstration offline") {
    DemonstrationPlaceholderView(state: .offline, onRetry: {})
        .padding(Theme.horizontalPadding)
        .background(Theme.bg)
}

#Preview("Demonstration loading") {
    DemonstrationPlaceholderView(state: .loading, onRetry: {})
        .padding(Theme.horizontalPadding)
        .background(Theme.bg)
}
