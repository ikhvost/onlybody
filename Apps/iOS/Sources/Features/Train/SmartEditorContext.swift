import Foundation

/// Detached handoff from daily generation to the shared workout editor.
nonisolated struct SmartEditorContext: Identifiable, Sendable {
    let id = UUID()
    var workout: WorkoutSnapshot
    var variant: SmartDailyVariant
    let isExisting: Bool
    let requiresSave: Bool
}
