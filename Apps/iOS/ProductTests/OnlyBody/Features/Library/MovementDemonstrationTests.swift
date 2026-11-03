import Foundation
import Testing
@testable import onlybody

@MainActor
struct MovementDemonstrationTests {
    private func makeViewModel(
        clock: any WorkoutTimeSource = ManualWorkoutTimeSource(),
        allowsVideoLoading: Bool = true,
        network: any NetworkAvailabilitySource = ManualNetworkAvailabilitySource()
    ) -> MovementDetailViewModel {
        var exercise = ExerciseSnapshot()
        exercise.name = "Dead Bug"
        return MovementDetailViewModel(
            exercise: exercise,
            demonstration: ExerciseDemonstrationCatalog.demonstration(for: exercise.name),
            bundleIdentifier: "ikhvost.onlybody",
            allowsVideoLoading: allowsVideoLoading,
            network: network,
            timeSource: clock
        )
    }

    @Test func openingPreparesPlayerWithoutPlayingAndPreviewsNeverLoad() {
        let viewModel = makeViewModel()
        #expect(viewModel.demonstrationState == .idle)
        #expect(viewModel.playerSessionID == nil)
        viewModel.setPlayerActive(true)
        #expect(viewModel.playerSessionID != nil)
        #expect(viewModel.demonstrationState == .loading)
        let preview = makeViewModel(allowsVideoLoading: false)
        preview.loadDemonstration()
        #expect(preview.playerSessionID == nil)
        #expect(preview.demonstrationState == .ready)
    }

    @Test func retryIgnoresEventsFromTheReplacedPlayer() throws {
        let viewModel = makeViewModel()
        viewModel.loadDemonstration()
        let oldSession = try #require(viewModel.playerSessionID)
        viewModel.receivePlayerEvent(.failed(.unavailable), sessionID: oldSession)
        #expect(viewModel.demonstrationState == .failed(.unavailable))
        #expect(viewModel.playerSessionID == nil)
        viewModel.loadDemonstration()
        let newSession = try #require(viewModel.playerSessionID)
        #expect(oldSession != newSession)
        viewModel.receivePlayerEvent(.failed(.connection), sessionID: oldSession)
        #expect(viewModel.demonstrationState == .loading)
        viewModel.receivePlayerEvent(.ready, sessionID: newSession)
        #expect(viewModel.demonstrationState == .ready)
        #expect(viewModel.playerTimeoutID == nil)
    }

    @Test func stalledLoadAndBufferingTimeOut() async throws {
        for buffering in [false, true] {
            let clock = ManualWorkoutTimeSource()
            let viewModel = makeViewModel(clock: clock)
            viewModel.loadDemonstration()
            let session = try #require(viewModel.playerSessionID)
            if buffering {
                viewModel.receivePlayerEvent(.ready, sessionID: session)
                viewModel.receivePlayerEvent(.playing, sessionID: session)
                viewModel.receivePlayerEvent(.buffering, sessionID: session)
            }
            let deadline = try #require(viewModel.playerTimeoutID)
            let task = Task { await viewModel.waitForPlayerTimeout(deadline) }
            await clock.waitForSleepers(1)
            clock.advance(seconds: 19)
            #expect(viewModel.demonstrationState == .loading)
            clock.advance(seconds: 1)
            await task.value
            #expect(viewModel.demonstrationState == .failed(.connection))
            #expect(viewModel.playerSessionID == nil)
        }
    }

    @Test func oldDeadlineCannotFailARetry() async throws {
        let clock = ManualWorkoutTimeSource()
        let viewModel = makeViewModel(clock: clock)
        viewModel.loadDemonstration()
        let deadline = try #require(viewModel.playerTimeoutID)
        let task = Task { await viewModel.waitForPlayerTimeout(deadline) }
        await clock.waitForSleepers(1)
        viewModel.closeDemonstration()
        viewModel.loadDemonstration()
        clock.advance(seconds: 20)
        await task.value
        #expect(viewModel.demonstrationState == .loading)
        #expect(viewModel.playerTimeoutID != deadline)
    }

    @Test func backgroundPausesAndReturningDoesNotPlay() throws {
        let viewModel = makeViewModel()
        viewModel.loadDemonstration()
        let session = try #require(viewModel.playerSessionID)
        viewModel.receivePlayerEvent(.ready, sessionID: session)
        viewModel.receivePlayerEvent(.playing, sessionID: session)
        viewModel.setPlayerActive(false)
        #expect(viewModel.demonstrationState == .paused)
        #expect(viewModel.playerPauseRevision == 1)
        viewModel.receivePlayerEvent(.playing, sessionID: session)
        #expect(viewModel.demonstrationState == .paused)
        viewModel.setPlayerActive(true)
        #expect(viewModel.demonstrationState == .paused)
        #expect(viewModel.playerSessionID == session)
        viewModel.closeDemonstration()
        viewModel.receivePlayerEvent(.playing, sessionID: session)
        #expect(viewModel.demonstrationState == .idle)
        #expect(viewModel.playerSessionID == nil)
    }

    @Test func returningFromAnInterruptedLoadPreparesThePlayerAgain() {
        let viewModel = makeViewModel()
        viewModel.loadDemonstration()
        viewModel.setPlayerActive(false)
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.playerTimeoutID == nil)
        viewModel.loadDemonstration()
        #expect(viewModel.playerSessionID == nil)
        viewModel.setPlayerActive(true)
        #expect(viewModel.demonstrationState == .loading)
        #expect(viewModel.playerSessionID != nil)
    }

    @Test func offlineReplacesPlayerAndReconnectPreparesWithoutPlaying() async throws {
        let network = ManualNetworkAvailabilitySource()
        let viewModel = makeViewModel(network: network)
        viewModel.setPlayerActive(true)
        let oldSession = try #require(viewModel.playerSessionID)
        let task = Task { await viewModel.monitorDemonstrationConnection() }
        defer { task.cancel() }
        for _ in 0..<1_000 {
            if network.continuation != nil { break }
            await Task.yield()
        }
        let continuation = try #require(network.continuation)
        continuation.yield(false)
        for _ in 0..<1_000 {
            if viewModel.demonstrationState == .offline { break }
            await Task.yield()
        }
        #expect(viewModel.demonstrationState == .offline)
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.playerTimeoutID == nil)
        viewModel.receivePlayerEvent(.failed(.connection), sessionID: oldSession)
        #expect(viewModel.demonstrationState == .offline)
        continuation.yield(true)
        for _ in 0..<1_000 {
            if viewModel.demonstrationState == .loading { break }
            await Task.yield()
        }
        #expect(viewModel.demonstrationState == .loading)
        #expect(viewModel.playerSessionID != oldSession)
        continuation.finish()
        await task.value
    }

    @Test func unknownExerciseRemainsAvailableWithoutMedia() {
        let exercise = ExerciseSnapshot()
        let viewModel = MovementDetailViewModel(exercise: exercise)
        viewModel.loadDemonstration()
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.exercise == exercise)
    }

    @Test func playbackErrorsDoNotChangeExerciseDetails() throws {
        let viewModel = makeViewModel()
        let original = viewModel.exercise
        viewModel.loadDemonstration()
        let session = try #require(viewModel.playerSessionID)
        viewModel.receivePlayerEvent(.failed(.connection), sessionID: session)
        #expect(viewModel.exercise == original)
        #expect(viewModel.demonstrationState == .failed(.connection))
    }
}
