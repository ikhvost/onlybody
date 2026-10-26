import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct ExerciseSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var primaryMuscle: String = ""
    var secondaryMuscles: [String] = []
    var equipment: [String] = []
    // Retained only for old-store round trips; generation ignores this legacy preference.
    var frequencyPreference: String = ExerciseFrequency.normal.rawValue

    /// Translated display only; `name` remains the catalog and persistence key.
    var displayName: String { CatalogLocalization.exercise(name) }

    func matchesSearch(_ query: String) -> Bool {
        query.isEmpty || displayName.localizedStandardContains(query) || name.localizedStandardContains(query)
    }

    var supportingMuscleLabel: String {
        supportingMuscles.isEmpty ? CatalogLocalization.label("None")
            : supportingMuscles.map { CatalogLocalization.label($0) }.joined(separator: ", ")
    }

    var muscleProfile: ExerciseMuscleProfile {
        ExerciseMuscleCatalog.profiles[name] ?? ExerciseMuscleProfile(
            primary: primaryMuscle == "Full Body" ? [] : Self.expandedLegacyGroups([primaryMuscle]),
            secondary: Self.expandedLegacyGroups(secondaryMuscles),
            isFullBody: primaryMuscle == "Full Body")
    }

    var primaryMuscles: [String] { muscleProfile.primary }
    var supportingMuscles: [String] { muscleProfile.secondary.filter { !primaryMuscles.contains($0) } }
    var primaryMuscleLabel: String { primaryMuscles.map { CatalogLocalization.label($0) }.joined(separator: ", ") }

    func matchesMuscleFilter(_ filter: String) -> Bool {
        filter == "All" || primaryMuscles.contains(filter) || (filter == "Full Body" && muscleProfile.isFullBody)
    }

    private static func expandedLegacyGroups(_ groups: [String]) -> [String] {
        groups.flatMap { $0 == "Arms" ? ["Biceps", "Triceps", "Forearms"] : [$0] }
    }

    var difficulty: ExerciseDifficulty { ExerciseDifficultyCatalog.levels[name] ?? .unrated }

    var equipmentLabel: String {
        equipment.isEmpty ? CatalogLocalization.label("None")
            : equipment.map { CatalogLocalization.label($0) }.joined(separator: ", ")
    }
}
