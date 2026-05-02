import Foundation
import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let workoutsRepository: any WorkoutRepository

    let workoutId: UUID

    var workoutName: String = ""
    var items: [WorkoutItem] = []
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0

    var completedSets: [String: Int] = [:]
    var actualReps: [String: Int] = [:]
    var weights: [Int: Double] = [:]

    var isComplete: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    let restTimer = RestTimer()

    private var elapsedTask: Task<Void, Never>?
    var elapsedSeconds: Int = 0

    var exerciseCount: Int { items.count }

    var currentItem: WorkoutItem? {
        guard items.indices.contains(currentExerciseIndex) else { return nil }
        return items[currentExerciseIndex]
    }

    var currentExerciseName: String {
        currentItem?.exercise?.name ?? ""
    }

    var currentTargetReps: Int {
        currentItem?.targetReps ?? 0
    }

    var currentSetsTotal: Int {
        currentItem?.sets ?? 0
    }

    var currentDisplayReps: Int {
        actualReps[currentKey] ?? currentTargetReps
    }

    var currentWeight: Double {
        weights[currentExerciseIndex] ?? 0
    }

    var completedSetsForCurrent: Int {
        countCompletedSets(for: currentExerciseIndex)
    }

    var totalCompletedSets: Int {
        var count = 0
        for i in items.indices {
            count += countCompletedSets(for: i)
        }
        return count
    }

    var canGoPrevious: Bool {
        currentExerciseIndex > 0
    }

    var canSkip: Bool {
        currentExerciseIndex < items.count - 1
    }

    var nextExerciseName: String {
        let nextIndex = currentExerciseIndex + 1
        guard items.indices.contains(nextIndex) else { return "" }
        return items[nextIndex].exercise?.name ?? ""
    }

    var currentKey: String {
        key(for: currentExerciseIndex, set: currentSetIndex)
    }

    init(
        workouts: any WorkoutRepository,
        workoutId: UUID
    ) {
        self.workoutsRepository = workouts
        self.workoutId = workoutId
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let workout = try await workoutsRepository.workout(by: workoutId) else {
                errorMessage = "Workout not found."
                return
            }

            workoutName = workout.name
            items = (workout.items ?? []).sorted { $0.order < $1.order }

            if items.isEmpty {
                errorMessage = "Workout has no exercises."
                return
            }

            currentExerciseIndex = 0
            currentSetIndex = 0
            completedSets = [:]
            actualReps = [:]
            weights = [:]
            isComplete = false
            elapsedSeconds = 0

            startElapsedTimer()
        } catch {
            errorMessage = "Could not load workout."
        }
    }

    func markSetDone() {
        guard currentItem != nil else { return }

        let reps = currentDisplayReps
        completedSets[currentKey] = reps

        let nextSet = currentSetIndex + 1

        if nextSet < currentSetsTotal {
            currentSetIndex = nextSet
            actualReps[currentKey] = reps
            restTimer.start(seconds: currentItem?.restSeconds ?? 45)
        } else if currentExerciseIndex + 1 < items.count {
            let nextName = nextExerciseName
            currentExerciseIndex += 1
            currentSetIndex = 0
            restTimer.start(seconds: currentItem?.restSeconds ?? 60, nextExercise: nextName)
        } else {
            isComplete = true
            elapsedTask?.cancel()
        }
    }

    func previousExercise() {
        guard canGoPrevious else { return }
        currentExerciseIndex -= 1
        currentSetIndex = 0
    }

    func skipExercise() {
        guard canSkip else { return }
        currentExerciseIndex += 1
        currentSetIndex = 0
    }

    func incrementReps() {
        actualReps[currentKey] = currentDisplayReps + 1
    }

    func decrementReps() {
        let value = max(0, currentDisplayReps - 1)
        actualReps[currentKey] = value
    }

    func incrementWeight() {
        weights[currentExerciseIndex] = currentWeight + 2.5
    }

    func decrementWeight() {
        let value = max(0, currentWeight - 2.5)
        weights[currentExerciseIndex] = value
    }

    func cleanup() {
        elapsedTask?.cancel()
        restTimer.skip()
    }

    func buildSessionItems() -> [SessionItem] {
        var result: [SessionItem] = []

        for (index, item) in items.enumerated() {
            let sessionItem = SessionItem()
            sessionItem.order = item.order
            sessionItem.exerciseName = item.exercise?.name ?? ""
            sessionItem.plannedSets = item.sets
            sessionItem.plannedReps = item.targetReps
            sessionItem.weightKg = weights[index]

            var setReps: [Int] = []
            for setIndex in 0..<item.sets {
                let k = key(for: index, set: setIndex)
                if let reps = completedSets[k] {
                    setReps.append(reps)
                }
            }
            sessionItem.setReps = setReps

            result.append(sessionItem)
        }

        return result
    }

    private func startElapsedTimer() {
        elapsedTask?.cancel()
        elapsedTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                elapsedSeconds += 1
            }
        }
    }

    private func key(for exerciseIndex: Int, set setIndex: Int) -> String {
        "\(exerciseIndex)-\(setIndex)"
    }

    private func countCompletedSets(for exerciseIndex: Int) -> Int {
        guard items.indices.contains(exerciseIndex) else { return 0 }
        let exercise = items[exerciseIndex]
        var count = 0
        for s in 0..<exercise.sets {
            if completedSets[key(for: exerciseIndex, set: s)] != nil {
                count += 1
            }
        }
        return count
    }
}
