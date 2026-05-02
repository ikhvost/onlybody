import Foundation
import Observation

@MainActor
@Observable
final class MusclePickerViewModel {
    let muscles: [Muscle]

    var selectedIDs: [String] = []

    var selectionSummary: String {
        muscles
            .filter { selectedIDs.contains($0.id) }
            .map(\.label)
            .joined(separator: " + ")
    }

    var canBuild: Bool {
        !selectedIDs.isEmpty
    }

    init() {
        self.muscles = [
            Muscle(id: "Chest", label: "Chest"),
            Muscle(id: "Back", label: "Back"),
            Muscle(id: "Shoulders", label: "Shoulders"),
            Muscle(id: "Arms", label: "Arms"),
            Muscle(id: "Core", label: "Core"),
            Muscle(id: "Quads", label: "Quads"),
            Muscle(id: "Glutes", label: "Glutes"),
            Muscle(id: "Hamstrings", label: "Hamstrings"),
            Muscle(id: "Calves", label: "Calves"),
            Muscle(id: "Full Body", label: "Full Body"),
            Muscle(id: "Upper", label: "Upper"),
            Muscle(id: "Lower", label: "Lower"),
        ]
    }

    func toggle(_ id: String) {
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(id)
        }
    }
}

struct Muscle: Identifiable {
    let id: String
    let label: String
}
