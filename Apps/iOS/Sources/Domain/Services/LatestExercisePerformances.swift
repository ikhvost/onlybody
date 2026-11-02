import Foundation

/// Finds the newest completed performance of each exercise across all workout templates.
nonisolated struct LatestExercisePerformances: Sendable {
    func items(in sessions: [SessionSnapshot]) -> [String: [SessionItemSnapshot]] {
        var result: [String: [SessionItemSnapshot]] = [:]
        let ordered = sessions.sorted {
            if $0.date != $1.date { return $0.date > $1.date }
            return $0.id.uuidString < $1.id.uuidString
        }
        for session in ordered {
            let completed = session.items.filter { !$0.setReps.isEmpty && !$0.exerciseName.isEmpty }
            for (name, items) in Dictionary(grouping: completed, by: \.exerciseName) where result[name] == nil {
                result[name] = items.sorted { $0.order < $1.order }
            }
        }
        return result
    }
}
