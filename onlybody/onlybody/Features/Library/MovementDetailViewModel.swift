import Foundation
import Observation

@MainActor
@Observable
final class MovementDetailViewModel {
    private let exercisesRepository: any ExerciseRepository
    private let timeSource: any WorkoutTimeSource
    private let allowsVideoLoading: Bool
    private let network: any NetworkAvailabilitySource
    private var hasNetwork = true

    let demonstration: ExerciseDemonstration?
    let playerDocument: YouTubeEmbedDocument?
    private(set) var demonstrationState: DemonstrationPlaybackState = .idle
    private(set) var playerSessionID: UUID?
    private(set) var playerTimeoutID: UUID?
    private(set) var playerPauseRevision = 0
    private(set) var isPlayerActive = true

    var exercise: ExerciseSnapshot
    var selectedFrequency: ExerciseFrequency
    var isSaving = false

    init(
        exercise: ExerciseSnapshot,
        exercises: any ExerciseRepository,
        demonstration: ExerciseDemonstration? = nil,
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "",
        allowsVideoLoading: Bool = true,
        network: any NetworkAvailabilitySource = SystemNetworkAvailabilitySource(),
        timeSource: any WorkoutTimeSource = SystemWorkoutTimeSource()
    ) {
        self.exercise = exercise
        self.exercisesRepository = exercises
        selectedFrequency = ExerciseFrequency(rawValue: exercise.frequencyPreference) ?? .normal
        self.demonstration = demonstration
        playerDocument = demonstration.flatMap {
            YouTubeEmbedDocument(demonstration: $0, bundleIdentifier: bundleIdentifier)
        }
        self.allowsVideoLoading = allowsVideoLoading
        self.network = network
        self.timeSource = timeSource
    }

    func loadDemonstration() {
        guard isPlayerActive, hasNetwork, let demonstration else { return }
        guard allowsVideoLoading else {
            demonstrationState = .ready
            return
        }
        guard demonstration.isValid, playerDocument != nil else {
            demonstrationState = .failed(.configuration)
            return
        }
        playerSessionID = UUID()
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
            if !available {
                playerSessionID = nil
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
        playerSessionID = nil
        playerTimeoutID = nil
        demonstrationState = .idle
    }

    private func failDemonstration(_ failure: DemonstrationFailure) {
        playerSessionID = nil
        playerTimeoutID = nil
        demonstrationState = .failed(failure)
    }

    func setFrequency(_ value: ExerciseFrequency) async {
        guard selectedFrequency != value, !isSaving else {
            return
        }

        let previousValue = selectedFrequency

        selectedFrequency = value
        exercise.frequencyPreference = value.rawValue
        isSaving = true

        do {
            try await exercisesRepository.save(exercise)
        } catch {
            selectedFrequency = previousValue
            exercise.frequencyPreference = previousValue.rawValue
        }

        isSaving = false
    }
}
