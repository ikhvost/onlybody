import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct SessionSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date.now
    var durationSeconds: Int = 0

    var workoutName: String = ""
    var items: [SessionItemSnapshot] = []

}
