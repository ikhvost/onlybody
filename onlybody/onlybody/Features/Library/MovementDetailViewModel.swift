import Foundation
import Observation

@MainActor
@Observable
final class MovementDetailViewModel {
    private let timeSource: any WorkoutTimeSource
    private let allowsVideoLoading: Bool
    private let usesLocalPlayer: Bool
    private let network: any NetworkAvailabilitySource
    private var hasNetwork = true
    private let youtubeConsent: YouTubeConsent
    private let trackingAuthorization: any TrackingAuthorizationSource
    private(set) var trackingPermission: TrackingPermission
    private(set) var isRequestingVideoPermission = false
    private var sessionConsentRevision: UUID?

    var needsYouTubeConsent: Bool { allowsVideoLoading && !youtubeConsent.isAllowed }
    var needsVideoPermission: Bool {
        allowsVideoLoading && (needsYouTubeConsent || trackingPermission != .authorized)
    }
    var canRequestVideoPermission: Bool {
        trackingPermission == .notDetermined || trackingPermission == .authorized
    }
    var externalVideoURL: URL? { demonstration?.watchURL }
    var consentRevision: UUID { youtubeConsent.revision }
    var playerSessionID: UUID? {
        guard !needsVideoPermission, sessionConsentRevision == consentRevision else { return nil }
        return preparedSessionID
    }

    func enableYouTubePlayback() async {
        guard !isRequestingVideoPermission, isPlayerActive, demonstration != nil else { return }
        isRequestingVideoPermission = true
        defer { isRequestingVideoPermission = false }
        youtubeConsent.allow()
        let revision = consentRevision
        trackingPermission = await trackingAuthorization.request()
        guard !Task.isCancelled, isPlayerActive, consentRevision == revision, youtubeConsent.isAllowed else { return }
        refreshYouTubeConsent()
        prepareDemonstration()
    }

    func allowYouTube() {
        youtubeConsent.allow()
        refreshYouTubeConsent()
    }

    func refreshYouTubeConsent() {
        guard needsVideoPermission || sessionConsentRevision != consentRevision else { return }
        closeDemonstration()
        prepareDemonstration()
    }

    let demonstration: ExerciseDemonstration?
    let playerDocument: YouTubeEmbedDocument?
    private(set) var demonstrationState: DemonstrationPlaybackState = .idle
    private var preparedSessionID: UUID?
    private(set) var playerTimeoutID: UUID?
    private(set) var playerPauseRevision = 0
    private(set) var isPlayerActive = true

    var exercise: ExerciseSnapshot

    var muscleDiagram: MuscleDiagram {
        MuscleDiagram(
            primaryMuscles: exercise.primaryMuscles,
            secondaryMuscles: exercise.supportingMuscles,
            isFullBody: exercise.muscleProfile.isFullBody)
    }

    var muscleDiagramDescription: String {
        let diagram = muscleDiagram
        var descriptions = [String(localized: .uiMuscleGroupsFrontAndBackViews)]
        if diagram.isFullBody { descriptions.append(String(localized: .uiFullBodyExercisePrimaryAndSecondaryGroupsAreHighlighted)) }
        if !diagram.primary.isEmpty {
            descriptions.append(String(localized: .uiPrimaryGroups(diagram.primary.map { CatalogLocalization.label($0.rawValue) }.joined(separator: ", "))))
        }
        if !diagram.secondary.isEmpty {
            descriptions.append(String(localized: .uiSecondaryGroups(diagram.secondary.map { CatalogLocalization.label($0.rawValue) }.joined(separator: ", "))))
        }
        if !diagram.hasHighlightedRegions { descriptions.append(String(localized: .uiNoMuscleGroupsSpecifiedMessage08A1)) }
        return descriptions.joined(separator: " ")
    }

    init(
        exercise: ExerciseSnapshot,
        demonstration: ExerciseDemonstration? = nil,
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "",
        allowsVideoLoading: Bool = true,
        localPlayerDocument: YouTubeEmbedDocument? = nil,
        network: any NetworkAvailabilitySource = SystemNetworkAvailabilitySource(),
        timeSource: any WorkoutTimeSource = SystemWorkoutTimeSource(),
        youtubeConsent: YouTubeConsent = YouTubeConsent(),
        trackingAuthorization: any TrackingAuthorizationSource = SystemTrackingAuthorizationSource()
    ) {
        self.youtubeConsent = youtubeConsent
        self.trackingAuthorization = trackingAuthorization
        trackingPermission = trackingAuthorization.status
        self.exercise = exercise
        self.demonstration = demonstration
        usesLocalPlayer = localPlayerDocument != nil
        playerDocument = localPlayerDocument ?? demonstration.flatMap {
            YouTubeEmbedDocument(demonstration: $0, bundleIdentifier: bundleIdentifier)
        }
        self.allowsVideoLoading = allowsVideoLoading
        self.network = network
        self.timeSource = timeSource
    }

    func loadDemonstration() {
        guard !needsVideoPermission, isPlayerActive, let demonstration else { return }
        guard hasNetwork else {
            demonstrationState = .offline
            return
        }
        sessionConsentRevision = consentRevision
        guard allowsVideoLoading else {
            if usesLocalPlayer { preparedSessionID = UUID() }
            demonstrationState = .ready
            return
        }
        guard demonstration.isValid, playerDocument != nil else {
            demonstrationState = .failed(.configuration)
            return
        }
        preparedSessionID = UUID()
        playerTimeoutID = UUID()
        demonstrationState = .loading
    }

    /// Preparing the player never starts playback; the embedded Play button does that.
    func prepareDemonstration() {
        guard demonstrationState == .idle else { return }
        loadDemonstration()
    }

    func monitorDemonstrationConnection() async {
        guard allowsVideoLoading, demonstration != nil else { return }
        for await available in network.updates() {
            guard !Task.isCancelled else { return }
            let wasAvailable = hasNetwork
            hasNetwork = available
            guard !needsVideoPermission else {
                closeDemonstration()
                continue
            }
            if !available {
                preparedSessionID = nil
                playerTimeoutID = nil
                demonstrationState = .offline
            } else if !wasAvailable {
                demonstrationState = .idle
                prepareDemonstration()
            }
        }
    }

    func receivePlayerEvent(_ event: DemonstrationPlayerEvent, sessionID: UUID) {
        guard sessionID == playerSessionID else { return }
        if case .failed(let failure) = event {
            failDemonstration(failure)
            return
        }
        guard isPlayerActive else { return }
        switch event {
        case .ready, .ended: demonstrationState = .ready
        case .playing: demonstrationState = .playing
        case .paused: demonstrationState = .paused
        case .buffering:
            demonstrationState = .loading
            if playerTimeoutID == nil { playerTimeoutID = UUID() }
            return
        case .failed: return
        }
        playerTimeoutID = nil
    }

    /// Called by a cancellable view task; tests advance an injected clock.
    func waitForPlayerTimeout(_ timeoutID: UUID) async {
        do {
            try await timeSource.sleep(for: .seconds(20))
            guard !Task.isCancelled, playerTimeoutID == timeoutID, demonstrationState == .loading else { return }
            failDemonstration(.connection)
        } catch {
            // Leaving the screen or receiving a player event cancels the deadline.
        }
    }

    func setPlayerActive(_ active: Bool) {
        isPlayerActive = active
        guard !active else {
            trackingPermission = trackingAuthorization.status
            refreshYouTubeConsent()
            prepareDemonstration()
            return
        }
        playerPauseRevision += 1
        playerTimeoutID = nil
        if demonstrationState == .loading {
            closeDemonstration()
            return
        }
        if playerSessionID != nil { demonstrationState = .paused }
    }

    func closeDemonstration() {
        preparedSessionID = nil
        playerTimeoutID = nil
        sessionConsentRevision = nil
        demonstrationState = .idle
    }

    private func failDemonstration(_ failure: DemonstrationFailure) {
        preparedSessionID = nil
        playerTimeoutID = nil
        demonstrationState = .failed(failure)
    }

}
