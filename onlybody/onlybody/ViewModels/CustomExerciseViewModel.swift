import Foundation
import Observation

@MainActor
@Observable
final class CustomExerciseViewModel {
    private let exercisesRepository: any ExerciseRepository

    var name = ""
    var primaryMuscle = ""
    var secondaryMuscles: [String] = []
    var selectedEquipment: [String] = []
    var isSaving = false
    var errorMessage: String? = nil

    let muscleOptions = [
        "Chest",
        "Back",
        "Shoulders",
        "Arms",
        "Core",
        "Quads",
        "Glutes",
        "Hamstrings",
        "Calves",
        "Full Body"
    ]

    let equipmentOptions = [
        "None",
        "Dumbbells",
        "Pull-up Bar",
        "Resistance Bands",
        "Kettlebell",
        "Barbell"
    ]

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !primaryMuscle.isEmpty
    }

    init(exercises: any ExerciseRepository) {
        self.exercisesRepository = exercises
    }

    func togglePrimaryMuscle(_ value: String) {
        primaryMuscle = value
        secondaryMuscles.removeAll { $0 == value }
    }

    func toggleSecondaryMuscle(_ value: String) {
        if secondaryMuscles.contains(value) {
            secondaryMuscles.removeAll { $0 == value }
        } else {
            secondaryMuscles.append(value)
        }
    }

    func toggleEquipment(_ value: String) {
        if value == "None" {
            selectedEquipment = selectedEquipment == ["None"] ? [] : ["None"]
            return
        }

        selectedEquipment.removeAll { $0 == "None" }

        if selectedEquipment.contains(value) {
            selectedEquipment.removeAll { $0 == value }
        } else {
            selectedEquipment.append(value)
        }
    }

    func save() async -> Bool {
        guard isValid else {
            return false
        }

        errorMessage = nil
        isSaving = true

        let exercise = Exercise()
        exercise.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        exercise.primaryMuscle = primaryMuscle
        exercise.secondaryMuscles = secondaryMuscles
        exercise.equipment = selectedEquipment.isEmpty ? ["None"] : selectedEquipment
        exercise.isCustom = true

        do {
            try await exercisesRepository.save(exercise)
            isSaving = false
            return true
        } catch {
            errorMessage = "Could not save custom exercise."
            isSaving = false
            return false
        }
    }
}
