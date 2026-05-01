import Observation

@MainActor
@Observable
final class MovementDetailViewModel {
    private let exercisesRepository: any ExerciseRepository

    var exercise: Exercise
    var selectedFrequency: String
    var isSaving = false

    init(exercise: Exercise, exercises: any ExerciseRepository) {
        self.exercise = exercise
        self.exercisesRepository = exercises
        selectedFrequency = exercise.frequencyPreference
    }

    func setFrequency(_ value: String) async {
        guard selectedFrequency != value else {
            return
        }

        let previousValue = selectedFrequency

        selectedFrequency = value
        exercise.frequencyPreference = value
        isSaving = true

        do {
            try await exercisesRepository.save(exercise)
        } catch {
            selectedFrequency = previousValue
            exercise.frequencyPreference = previousValue
        }

        isSaving = false
    }
}
