import Foundation

/// Editorial planning metadata. A missing entry is never considered eligible for automatic selection.
nonisolated struct SmartExerciseMetadata: Codable, Equatable, Sendable {
    let movement: SmartMovement
    let role: SmartExerciseRole
    let family: String
    let repetitionRule: ExerciseRepetitionRule
    let repetitionSeconds: Int
    let setupSeconds: Int
    let transitionSeconds: Int
    let loads: Set<ExerciseLoad>
}
