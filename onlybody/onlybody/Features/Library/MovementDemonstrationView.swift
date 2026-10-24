import SwiftUI

struct MovementDemonstrationView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    let viewModel: MovementDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: "Demonstration", size: Theme.type11, tracking: 0.8)

            if let demonstration = viewModel.demonstration {
                if let sessionID = viewModel.playerSessionID, let document = viewModel.playerDocument {
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
                        Text("Loading video…")
                            .font(Theme.fontSans(Theme.type13))
                            .foregroundStyle(Theme.text2)
                            .accessibilityIdentifier("demonstration.loading")
                    }
                } else {
                    DemonstrationPlaceholderView(state: viewModel.demonstrationState, onRetry: viewModel.loadDemonstration)
                }

                Text("Video by \(demonstration.author)")
                    .font(Theme.fontSans(Theme.type12))
                    .foregroundStyle(Theme.text2)
                    .accessibilityIdentifier("demonstration.author")

                if let url = demonstration.watchURL {
                    Button("Open on YouTube") { openURL(url) }
                        .font(Theme.fontSans(Theme.type14, .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(minHeight: Theme.space44)
                        .accessibilityLabel("Open \(demonstration.exerciseName) on YouTube")
                        .accessibilityIdentifier("demonstration.openYouTube")
                }
            } else {
                Text("No demonstration is available for this exercise yet.")
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
        .onAppear { viewModel.setPlayerActive(scenePhase == .active) }
        .onChange(of: scenePhase) { _, phase in viewModel.setPlayerActive(phase == .active) }
        .onDisappear { viewModel.closeDemonstration() }
    }
}
