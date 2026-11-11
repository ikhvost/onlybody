import Foundation

/// All automatic selection constraints, independent of persistence and screen state.
nonisolated struct SmartWorkoutConfiguration: Sendable, Equatable, Codable {
    private typealias CodingKeys = SmartConfigurationCodingKey
    var targetMuscleGroups: [String]
    var durationMinutes: Int
    var restSeconds: Int?
    // Preserve the stored JSON value for older app versions; not a selection setting.
    private var legacyLevel = "beginner"
    var equipmentMode: SmartEquipmentMode
    var availableEquipment: Set<String>
    var excludedLoads: Set<ExerciseLoad>
    // Compatibility only: old permanent exclusions no longer affect selection.
    var excludedExercises: Set<String>
    var excludedRegions: Set<SmartBodyRegion>

    init(targetMuscleGroups: [String], durationMinutes: Int = 30, restSeconds: Int? = nil,
         equipmentMode: SmartEquipmentMode = .confirmed,
         availableEquipment: Set<String> = [], excludedLoads: Set<ExerciseLoad> = [], excludedExercises: Set<String> = [],
         excludedRegions: Set<SmartBodyRegion> = []) {
        self.targetMuscleGroups = targetMuscleGroups
        self.durationMinutes = durationMinutes
        self.restSeconds = restSeconds
        self.equipmentMode = equipmentMode
        self.availableEquipment = availableEquipment
        self.excludedLoads = excludedLoads
        self.excludedExercises = excludedExercises
        self.excludedRegions = excludedRegions
    }

    /// Older payloads have no regions. Existing constraints remain required and are never silently discarded.
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        targetMuscleGroups = try values.decode([String].self, forKey: .targetMuscleGroups)
        durationMinutes = try values.decode(Int.self, forKey: .durationMinutes)
        restSeconds = try values.decodeIfPresent(Int.self, forKey: .restSeconds)
        legacyLevel = try values.decode(String.self, forKey: .legacyLevel)
        equipmentMode = try values.decode(SmartEquipmentMode.self, forKey: .equipmentMode)
        availableEquipment = try values.decode(Set<String>.self, forKey: .availableEquipment)
        excludedLoads = try values.decode(Set<ExerciseLoad>.self, forKey: .excludedLoads)
        excludedExercises = try values.decode(Set<String>.self, forKey: .excludedExercises)
        excludedRegions = try values.decodeIfPresent(Set<SmartBodyRegion>.self, forKey: .excludedRegions) ?? []
    }
}
