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
        let deadline = time.now.addingTimeInterval(TimeInterval(seconds))
        task = Task { [weak self, time] in
            while !Task.isCancelled {
                do { try await time.sleep(for: .seconds(1)) } catch { return }
                guard !Task.isCancelled, let self else { return }
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

    func skip() {
        task?.cancel()
        task = nil
        remainingSeconds = 0
        isActive = false
        nextExerciseName = ""
    }
}
