import Foundation
import Observation

@MainActor
@Observable
final class SmartReplacementViewModel {
    let item: WorkoutItemSnapshot
    private let items: [WorkoutItemSnapshot]
    private let configuration: SmartWorkoutConfiguration
    private let catalog: [ExerciseSnapshot]
    var equipmentUnavailable: Bool?
    var showsConflicts = false
    var pendingConflict: ExerciseSnapshot?

    init(item: WorkoutItemSnapshot, items: [WorkoutItemSnapshot], configuration: SmartWorkoutConfiguration, catalog: [ExerciseSnapshot]) {
        self.item = item
        self.items = items
        self.configuration = configuration
        self.catalog = catalog
    }

    var alternatives: [ExerciseSnapshot] {
        let generator = SmartSelectionGenerator()
        let usedFamilies = Set(items.filter { $0.id != item.id }.compactMap { $0.exercise?.smartMetadata?.family })
        let missing = Set(item.exercise?.equipment.filter { $0 != "None" } ?? [])
        return catalog.filter { exercise in
            guard exercise.name != item.exercise?.name,
                  generator.isEligible(exercise, configuration: configuration, ignoringLoads: showsConflicts),
                  let metadata = exercise.smartMetadata, !usedFamilies.contains(metadata.family) else { return false }
            if equipmentUnavailable == true, !missing.isDisjoint(with: exercise.equipment) { return false }
            // Keep the role and movement need of the replaced slot.
            return metadata.role == item.exercise?.smartMetadata?.role
                && metadata.movement == item.exercise?.smartMetadata?.movement
                && !Set(exercise.primaryMuscles).isDisjoint(with: item.exercise?.primaryMuscles ?? [])
        }.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    func conflicts(_ exercise: ExerciseSnapshot) -> [ExerciseLoad] {
        SmartSelectionGenerator().conflicts(exercise, configuration: configuration)
    }
    var conflictMessage: String {
        guard let pendingConflict else { return "" }
        return conflicts(pendingConflict).map(\.label).joined(separator: " · ") + "\n" + String(localized: .smartConflictHint)
    }
}
