import Foundation
import Observation

@MainActor
@Observable
final class RestTimer {
    var remainingSeconds: Int = 0
    var isActive: Bool = false
    var nextExerciseName: String = ""

    private var task: Task<Void, Never>?

    func start(seconds: Int, nextExercise: String = "") {
        remainingSeconds = seconds
        nextExerciseName = nextExercise
        isActive = true
        task?.cancel()
        task = Task {
            for _ in 0..<seconds {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1
            }
            isActive = false
        }
    }

    func skip() {
        task?.cancel()
        remainingSeconds = 0
        isActive = false
    }
}
