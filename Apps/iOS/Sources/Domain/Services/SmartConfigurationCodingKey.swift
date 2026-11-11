import Foundation

/// Stable JSON keys for stored Smart configuration; kept separate from SwiftData's schema.
nonisolated enum SmartConfigurationCodingKey: String, CodingKey {
    case targetMuscleGroups, durationMinutes, restSeconds, equipmentMode
    case legacyLevel = "level"
    case availableEquipment, excludedLoads, excludedExercises, excludedRegions
}
