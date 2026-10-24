import Foundation
import Observation

struct MovementConfig: Identifiable {
    var id = UUID()
    let exercise: ExerciseSnapshot
    var sets: Int = 3
    var reps: Int = 12
    var restSeconds: Int = 45
}
