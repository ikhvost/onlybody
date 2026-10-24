import Observation

@MainActor
@Observable
final class MovementDetailViewModel {
    private let exercisesRepository: any ExerciseRepository

    var exercise: ExerciseSnapshot
    var selectedFrequency: ExerciseFrequency
    var isSaving = false

    init(exercise: ExerciseSnapshot, exercises: any ExerciseRepository) {
        self.exercise = exercise
        self.exercisesRepository = exercises
        selectedFrequency = ExerciseFrequency(rawValue: exercise.frequencyPreference) ?? .normal
    }

    func setFrequency(_ value: ExerciseFrequency) async {
        guard selectedFrequency != value, !isSaving else {
            return
        }

        let previousValue = selectedFrequency

        selectedFrequency = value
        exercise.frequencyPreference = value.rawValue
        isSaving = true

        do {
            try await exercisesRepository.save(exercise)
        } catch {
            selectedFrequency = previousValue
            exercise.frequencyPreference = previousValue.rawValue
        }

        isSaving = false
    }
}
