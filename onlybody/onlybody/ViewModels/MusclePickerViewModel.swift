import Foundation
import Observation

@MainActor
@Observable
final class MusclePickerViewModel {
    let muscles = [
        "Chest",
        "Back",
        "Shoulders",
        "Arms",
        "Core",
        "Quads",
        "Glutes",
        "Hamstrings",
        "Calves",
        "Full Body",
        "Upper",
        "Lower",
    ]

    var selectedIDs: [String] = []

    var selectionSummary: String {
        muscles
            .filter { selectedIDs.contains($0) }
            .joined(separator: " + ")
    }

    var canBuild: Bool {
        !selectedIDs.isEmpty
    }

    func toggle(_ id: String) {
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(id)
        }
    }
}
