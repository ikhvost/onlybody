import SwiftUI

struct MovementDemonstrationView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    let viewModel: MovementDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiDemonstration), size: Theme.type11, tracking: 0.8)

            if let demonstration = viewModel.demonstration {
                if viewModel.needsVideoPermission {
                    YouTubeConsentView(
                        canRequestPermission: viewModel.canRequestVideoPermission,
                        isRequestingPermission: viewModel.isRequestingVideoPermission,
                        onAllow: { Task { await viewModel.enableYouTubePlayback() } }
                    )
                } else if viewModel.isPlayerActive,
                          let sessionID = viewModel.playerSessionID, let document = viewModel.playerDocument {
                    YouTubePlayerView(
                        document: document,
                        sessionID: sessionID,
                        pauseRevision: viewModel.playerPauseRevision,
                        isActive: viewModel.isPlayerActive,
                        onEvent: viewModel.receivePlayerEvent,
                        onOpenURL: { openURL($0) }
                    )
                    .id(sessionID)
                    .frame(minWidth: Theme.demonstrationMinimumWidth, maxWidth: .infinity)
                    .frame(height: Theme.demonstrationHeight)
                    .accessibilityIdentifier("demonstration.player")

                    if viewModel.demonstrationState == .loading {
                        Text(.uiLoadingVideo)
                            .font(Theme.fontSans(Theme.type13))
                            .foregroundStyle(Theme.text2)
                            .accessibilityIdentifier("demonstration.loading")
                    }
                } else {
                    DemonstrationPlaceholderView(state: viewModel.demonstrationState, onRetry: viewModel.loadDemonstration)
                }

                if let url = viewModel.externalVideoURL {
                    Button(String(localized: .uiWatchOnYoutube)) { openURL(url) }
                        .font(Theme.fontSans(Theme.type14, .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(minHeight: Theme.space44)
                        .accessibilityIdentifier("demonstration.openYouTube")
                }

                Text(String(localized: .uiVideoBy(demonstration.author)))
                    .font(Theme.fontSans(Theme.type12))
                    .foregroundStyle(Theme.text2)
                    .accessibilityIdentifier("demonstration.author")
            } else {
                Text(.uiNoDemonstrationIsAvailableForThisExerciseYet)
                    .accessibilityIdentifier("demonstration.unavailable")
                    .font(Theme.fontSans(Theme.type14))
                    .foregroundStyle(Theme.text2)
            }
        }
        .task { await viewModel.monitorDemonstrationConnection() }
        .task(id: viewModel.playerTimeoutID) {
            if let timeoutID = viewModel.playerTimeoutID {
                await viewModel.waitForPlayerTimeout(timeoutID)
            }
        }
        .onChange(of: viewModel.consentRevision) { _, _ in viewModel.refreshYouTubeConsent() }
        .onAppear { viewModel.setPlayerActive(scenePhase == .active) }
        .onChange(of: scenePhase) { _, phase in viewModel.setPlayerActive(phase == .active) }
        .onDisappear {
            viewModel.setPlayerActive(false)
            viewModel.closeDemonstration()
        }
    }
}
