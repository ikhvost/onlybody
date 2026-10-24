import Foundation
import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let sessionsRepository: any SessionRepository

    let workoutId: UUID

    var workoutName: String = ""
    var items: [WorkoutItemSnapshot] = []
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0

    var completedSets: [String: Int] = [:]
    private var completedWeights: [String: Double] = [:]
    var actualReps: [String: Int] = [:]
    var weights: [Int: Double] = [:]

    var isComplete: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    let restTimer: RestTimer
    private let time: any WorkoutTimeSource
    private var startedAt: Date?
    private var finishedAt: Date?
    private let sessionID = UUID()
    private(set) var saveState: SessionSaveState = .idle

    private var elapsedTask: Task<Void, Never>?
    var saveTask: Task<Void, Never>?
    var elapsedSeconds: Int = 0

    var currentItem: WorkoutItemSnapshot? {
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
        sessions: any SessionRepository,
        workoutId: UUID,
        time: any WorkoutTimeSource = SystemWorkoutTimeSource()
    ) {
        self.workoutsRepository = workouts
        self.sessionsRepository = sessions
        self.workoutId = workoutId
        self.time = time
        self.restTimer = RestTimer(time: time)
    }

    func load() async {
        guard !isLoading, startedAt == nil else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let workout = try await workoutsRepository.workout(by: workoutId) else {
                errorMessage = "Workout not found."
                return
            }

            workoutName = workout.name
            items = (workout.items).sorted { $0.order < $1.order }

            if items.isEmpty {
                errorMessage = "Workout has no exercises."
                return
            }

            currentExerciseIndex = 0
            currentSetIndex = 0
            completedSets = [:]
            completedWeights = [:]
            actualReps = [:]
            weights = [:]
            isComplete = false
            elapsedSeconds = 0

            startedAt = time.now
            startElapsedTimer()
        } catch {
            errorMessage = "Could not load workout."
        }
    }

    func markSetDone() {
        guard currentItem != nil, !isComplete, saveState == .idle else { return }

        let reps = currentDisplayReps
        completedSets[currentKey] = reps
        completedWeights[currentKey] = currentWeight

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
            finishTiming()
            elapsedTask?.cancel()
            restTimer.skip()
            beginSave()
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
        // saveTask intentionally not cancelled — in-flight save must complete.
    }

    func endSession() async {
        guard !items.isEmpty else { return }
        isComplete = true
        finishTiming()
        restTimer.skip()
        beginSave()
        await saveTask?.value
    }

    func retrySave() async {
        await endSession()
    }

    func buildSessionItems() -> [SessionItemSnapshot] {
        var result: [SessionItemSnapshot] = []

        for (index, item) in items.enumerated() {
            var sessionItem = SessionItemSnapshot()
            sessionItem.order = item.order
            sessionItem.exerciseName = item.exercise?.name ?? ""
            sessionItem.plannedSets = item.sets
            sessionItem.plannedReps = item.targetReps
            sessionItem.weightKg = weights[index] ?? 0

            var setReps: [Int] = []
            var setWeights: [Double] = []
            for setIndex in 0..<max(0, item.sets) {
                let k = key(for: index, set: setIndex)
                if let reps = completedSets[k] {
                    setReps.append(reps)
                    setWeights.append(completedWeights[k] ?? 0)
                }
            }
            sessionItem.setReps = setReps
            sessionItem.setWeightsKg = setWeights

            result.append(sessionItem)
        }

        return result
    }

    private func beginSave() {
        guard saveState != .saving, saveState != .saved else { return }
        saveState = .saving
        errorMessage = nil
        saveTask = Task { [self] in await saveSession() }
    }

    private func saveSession() async {
        var session = SessionSnapshot()
        session.id = sessionID
        session.date = finishedAt ?? time.now
        session.durationSeconds = elapsedSeconds

        session.workoutName = workoutName
        session.items = buildSessionItems()

        do {
            try await sessionsRepository.save(session)
            saveState = .saved
        } catch {
            saveState = .failed
            errorMessage = "Could not save session."
        }
    }

    private func finishTiming() {
        if finishedAt == nil { finishedAt = time.now }
        if let startedAt, let finishedAt {
            elapsedSeconds = max(0, Int(finishedAt.timeIntervalSince(startedAt)))
        }
        elapsedTask?.cancel()
    }

    private func startElapsedTimer() {
        elapsedTask?.cancel()
        elapsedTask = Task { [weak self, time] in
            while !Task.isCancelled {
                do { try await time.sleep(for: .seconds(1)) } catch { return }
                guard !Task.isCancelled, let self, let startedAt else { return }
                elapsedSeconds = max(0, Int(time.now.timeIntervalSince(startedAt)))
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
        for set in 0..<max(0, exercise.sets) where completedSets[key(for: exerciseIndex, set: set)] != nil {
            count += 1
        }
        return count
    }
}
