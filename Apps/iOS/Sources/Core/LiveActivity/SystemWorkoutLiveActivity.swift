import ActivityKit
import Foundation
import OSLog

@MainActor
final class SystemWorkoutLiveActivity: WorkoutLiveActivity {
    private let logger = Logger(subsystem: "WorkoutActivity", category: "Lifecycle")
    private var activityID: String?
    private var lastState: WorkoutActivityState?
    private var operation: Task<Void, Never>?

    init() {
        // Sessions are in memory. Snapshot the orphaned activities before any new session starts.
        let abandoned = Activity<WorkoutActivityAttributes>.activities.map(\.id)
        Task {
            for id in abandoned {
                await Self.endActivity(id: id)
            }
        }
    }

    func start(sessionID: UUID, workoutName: String, state: WorkoutActivityState) {
        guard activityID == nil, ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WorkoutActivityAttributes(sessionID: sessionID, workoutName: String(workoutName.prefix(100)))
        do {
            let activity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil), pushType: nil)
            activityID = activity.id
            lastState = state
        } catch {
            logger.error("Could not start workout Live Activity: \(error.localizedDescription)")
        }
    }

    func update(_ state: WorkoutActivityState) {
        guard let activityID, state != lastState else { return }
        lastState = state
        let previous = operation
        operation = Task {
            await previous?.value
            guard lastState == state, self.activityID == activityID else { return }
            await Self.updateActivity(id: activityID, state: state)
        }
    }

    func end() {
        guard let activityID else { return }
        self.activityID = nil
        lastState = nil
        let previous = operation
        operation = nil
        Task {
            await previous?.value
            await Self.endActivity(id: activityID)
        }
    }

    // Look up SDK handles on the executor where their asynchronous operations run.
    @concurrent private static func updateActivity(id: String, state: WorkoutActivityState) async {
        let activity = Activity<WorkoutActivityAttributes>.activities.first { $0.id == id }
        await activity?.update(.init(state: state, staleDate: nil))
    }

    @concurrent private static func endActivity(id: String) async {
        let activity = Activity<WorkoutActivityAttributes>.activities.first { $0.id == id }
        await activity?.end(nil, dismissalPolicy: .immediate)
    }
}
