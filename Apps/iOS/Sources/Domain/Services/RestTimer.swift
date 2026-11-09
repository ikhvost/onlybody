import Foundation
import Observation

@MainActor
@Observable
final class RestTimer {
    private(set) var remainingSeconds = 0
    private(set) var isActive = false
    private(set) var nextExerciseName = ""

    private let time: any WorkoutTimeSource
    @ObservationIgnored var onFinished: @MainActor () -> Void
    private(set) var deadline: Date?
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
                guard !Task.isCancelled, let self else { return }
                synchronize()
            }
        }
    }

    /// Extends the actual deadline, including elapsed time since the last tick.
    func add(seconds: Int) {
        synchronize()
        guard seconds > 0, let deadline else { return }
        let extended = deadline.addingTimeInterval(TimeInterval(seconds))
        self.deadline = extended
        remainingSeconds = max(0, Int(ceil(extended.timeIntervalSince(time.now))))
    }

    /// Reconciles the display after suspension and finishes the current rest at most once.
    func synchronize() {
        guard let deadline else { return }
        remainingSeconds = max(0, Int(ceil(deadline.timeIntervalSince(time.now))))
        guard remainingSeconds == 0 else { return }
        skip()
        onFinished()
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
