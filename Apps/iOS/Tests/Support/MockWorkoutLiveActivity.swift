import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockWorkoutLiveActivity: WorkoutLiveActivity {
    private(set) var workoutName: String?
    private(set) var states: [WorkoutActivityState] = []
    private(set) var hasEnded = false

    func start(sessionID: UUID, workoutName: String, state: WorkoutActivityState) {
        self.workoutName = workoutName
        states.append(state)
    }

    func update(_ state: WorkoutActivityState) {
        states.append(state)
    }

    func end() {
        hasEnded = true
    }
}
