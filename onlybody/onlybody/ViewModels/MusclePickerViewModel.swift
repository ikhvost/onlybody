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
            .joined(separator: " + ")
    }

    var canBuild: Bool {
        !selectedMuscles.isEmpty
    }

    func toggle(_ muscle: String) {
        if let index = selectedMuscles.firstIndex(of: muscle) {
            selectedMuscles.remove(at: index)
        } else {
            selectedMuscles.append(muscle)
        }
    }
}
