import Foundation
import Observation

@MainActor
@Observable
final class MusclePickerViewModel {
    let muscles = ExerciseCatalog.sessionTargets

    var selectedMuscles: [String] = []

    var selectionSummary: String {
        muscles
            .filter { selectedMuscles.contains($0) }
            .map { CatalogLocalization.label($0) }
            .joined(separator: " + ")
    }

    var canBuild: Bool {
        SmartTargetPolicy().isValid(selectedMuscles)
    }

    func canToggle(_ muscle: String) -> Bool {
        SmartTargetPolicy().canToggle(muscle, in: selectedMuscles)
    }

    func toggle(_ muscle: String) {
        selectedMuscles = SmartTargetPolicy().toggling(muscle, in: selectedMuscles)
    }
}
