import Foundation
import Observation

/// Reads historical name snapshots; catalog UUID changes never hide past performances.
@MainActor
@Observable
final class ExerciseHistoryViewModel {
    let exerciseName: String
    private let sessions: any SessionRepository
    private(set) var entries: [ExerciseHistoryEntry] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(exerciseName: String, sessions: any SessionRepository) {
        self.exerciseName = exerciseName
        self.sessions = sessions
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let history = try await sessions.allSessions()
            entries = history.compactMap { session in
                let matchingItems = session.items.filter {
                    $0.exerciseName == exerciseName && !$0.setReps.isEmpty
                }.sorted { $0.order < $1.order }
                guard !matchingItems.isEmpty else { return nil }
                return ExerciseHistoryEntry(
                    id: session.id, date: session.date, workoutName: session.workoutName, items: matchingItems
                )
            }.sorted {
                if $0.date != $1.date { return $0.date > $1.date }
                return $0.id.uuidString < $1.id.uuidString
            }
        } catch {
            errorMessage = "Could not load exercise history."
        }
    }
}
