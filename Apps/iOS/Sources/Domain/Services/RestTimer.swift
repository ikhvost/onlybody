import Foundation
import Observation

@MainActor
@Observable
final class RestTimer {
    private(set) var remainingSeconds = 0
    private(set) var isActive = false
    private(set) var nextExerciseName = ""

    private let time: any WorkoutTimeSource
    private let onFinished: @MainActor () -> Void
    private var deadline: Date?
    private var task: Task<Void, Never>?

    init(time: any WorkoutTimeSource = SystemWorkoutTimeSource(), onFinished: @escaping @MainActor () -> Void = {}) {
        self.time = time
        self.onFinished = onFinished
    }

    func start(seconds: Int, nextExercise: String = "") {
        skip()
        guard seconds > 0 else { return }
        remainingSeconds = seconds
        nextExerciseName = nextExercise
        isActive = true
        deadline = time.now.addingTimeInterval(TimeInterval(seconds))
        task = Task { [weak self, time] in
            while !Task.isCancelled {
                do { try await time.sleep(for: .seconds(1)) } catch { return }
                guard !Task.isCancelled, let self, let deadline = self.deadline else { return }
                remainingSeconds = max(0, Int(ceil(deadline.timeIntervalSince(time.now))))
                if remainingSeconds == 0 {
                    isActive = false
                    task = nil
                    onFinished()
                    return
                }
            }
        }
    }

    /// Extends the actual deadline, including elapsed time since the last tick.
    func add(seconds: Int) {
        guard isActive, seconds > 0, let deadline else { return }
        self.deadline = deadline.addingTimeInterval(TimeInterval(seconds))
        remainingSeconds = max(0, Int(ceil((self.deadline ?? deadline).timeIntervalSince(time.now))))
    }

    func skip() {
        deadline = nil
        task?.cancel()
        task = nil
        remainingSeconds = 0
        isActive = false
        nextExerciseName = ""
    }
}
