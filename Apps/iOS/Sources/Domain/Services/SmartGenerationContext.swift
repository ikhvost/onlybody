import Foundation

/// Stable main exercises and explicit variability make generation reproducible in tests.
nonisolated struct SmartGenerationContext: Sendable {
    var mainExerciseNames: [String] = []
    var previousExerciseNames: [String] = []
    var variationSeed: UInt64 = 0
}
