import Foundation
import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let sessionsRepository: any SessionRepository
    private let preferences: WorkoutPreferences

    let workoutId: UUID

    private let alwaysShowsWeight: Bool
    private var revealedWeightExercises: Set<Int> = []
    var repsInput: String?
    var weightInput: String?
    var invalidNumbers: Set<String> = []
    var hasInvalidNumbers: Bool { !invalidNumbers.isEmpty }
    var showsWeight: Bool { alwaysShowsWeight || currentWeight > 0 || revealedWeightExercises.contains(currentExerciseIndex) }
    var completedSetCount: Int { completedSets.count }
    var repsText: String { repsInput ?? String(currentDisplayReps) }
    var weightText: String { weightInput ?? displayedWeight.formatted(.number.precision(.fractionLength(0...2)).grouping(.never)) }
    var canClose: Bool { saveState == .saved || saveState == .noCompletedSets }

    func revealWeight() { revealedWeightExercises.insert(currentExerciseIndex) }

    func enterReps(_ text: String) {
        repsInput = text
        guard let value = WorkoutNumberParser().integer(text, minimum: 0) else { invalidNumbers.insert("reps"); return }
        invalidNumbers.remove("reps")
        actualReps[currentKey] = value
    }

    func enterWeight(_ text: String, locale: Locale = .current) {
        weightInput = text
        guard let value = WorkoutNumberParser().weight(text, locale: locale) else { invalidNumbers.insert("weight"); return }
        invalidNumbers.remove("weight")
        weights[currentExerciseIndex] = preferences.weightUnit.kilograms(from: value)
        revealWeight()
    }

    private func clearNumberInputs() { repsInput = nil; weightInput = nil; invalidNumbers = [] }

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
    private let stopRestCue: @MainActor () -> Void
    private var startedAt: Date?
    private var finishedAt: Date?
    private var isDiscarded = false
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

    var displayedWeight: Double { preferences.weightUnit.value(fromKilograms: currentWeight) }
    var weightUnitSymbol: String { preferences.weightUnit.rawValue }

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
        time: any WorkoutTimeSource = SystemWorkoutTimeSource(),
        preferences: WorkoutPreferences = WorkoutPreferences(),
        alwaysShowsWeight: Bool = false,
        playRestCue: @escaping @MainActor () -> Void = {},
        stopRestCue: @escaping @MainActor () -> Void = {}
    ) {
        self.alwaysShowsWeight = alwaysShowsWeight
        self.workoutsRepository = workouts
        self.sessionsRepository = sessions
        self.workoutId = workoutId
        self.time = time
        self.preferences = preferences
        self.restTimer = RestTimer(time: time) {
            if preferences.isTimerSoundEnabled { playRestCue() }
        }
        self.stopRestCue = stopRestCue
    }

    func load() async {
        guard !isLoading, startedAt == nil else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let workout = try await workoutsRepository.workout(by: workoutId) else {
                errorMessage = String(localized: .uiWorkoutNotFound)
                return
            }

            workoutName = workout.name
            items = (workout.items).sorted { $0.order < $1.order }

            if items.isEmpty {
                errorMessage = String(localized: .uiWorkoutHasNoExercises)
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
            errorMessage = String(localized: .uiCouldNotLoadWorkout)
        }
    }

    func markSetDone() {
        guard !hasInvalidNumbers, currentItem != nil, !isComplete, !isDiscarded, saveState == .idle else { return }
        stopRestCue()

        let reps = currentDisplayReps
        completedSets[currentKey] = reps
        completedWeights[currentKey] = currentWeight

        clearNumberInputs()
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
        guard canGoPrevious, !hasInvalidNumbers else { return }
        clearNumberInputs()
        currentExerciseIndex -= 1
        currentSetIndex = 0
    }

    func skipExercise() {
        guard canSkip, !hasInvalidNumbers else { return }
        clearNumberInputs()
        currentExerciseIndex += 1
        currentSetIndex = 0
    }

    func incrementReps() {
        guard !hasInvalidNumbers else { return }
        actualReps[currentKey] = min(Int(Int32.max), currentDisplayReps + 1)
        repsInput = nil
    }

    func decrementReps() {
        guard !hasInvalidNumbers else { return }
        repsInput = nil
        let value = max(0, currentDisplayReps - 1)
        actualReps[currentKey] = value
    }

    func incrementWeight() {
        guard !hasInvalidNumbers else { return }
        weightInput = nil
        revealWeight()
        weights[currentExerciseIndex] = preferences.weightUnit.stepping(kilograms: currentWeight, increasing: true)
    }

    func decrementWeight() {
        guard !hasInvalidNumbers else { return }
        weightInput = nil
        revealWeight()
        weights[currentExerciseIndex] = preferences.weightUnit.stepping(kilograms: currentWeight, increasing: false)
    }

    func cleanup() {
        stopRestCue()
        elapsedTask?.cancel()
        restTimer.skip()
        // saveTask intentionally not cancelled — in-flight save must complete.
    }

    /// Ends an active session without writing to history. Already-started saves cannot be discarded.
    @discardableResult
    func discardSession() -> Bool {
        guard !isComplete, saveState == .idle, !isDiscarded else { return false }
        isDiscarded = true
        finishTiming()
        cleanup()
        return true
    }

    func endSession() async {
        guard !items.isEmpty, !isDiscarded, !hasInvalidNumbers else { return }
        stopRestCue()
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

            let completed = completedSets.compactMap { entry -> (set: Int, reps: Int, weight: Double)? in
                let parts = entry.key.split(separator: "-")
                guard parts.count == 2, Int(parts[0]) == index, let set = Int(parts[1]),
                      set >= 0, set < item.sets else { return nil }
                return (set, entry.value, completedWeights[entry.key] ?? 0)
            }.sorted { $0.set < $1.set }
            sessionItem.setReps = completed.map(\.reps)
            sessionItem.setWeightsKg = completed.map(\.weight)

            result.append(sessionItem)
        }

        return result
    }

    private func beginSave() {
        guard !isDiscarded, saveState != .saving, saveState != .saved, saveState != .noCompletedSets else { return }
        guard !completedSets.isEmpty else { saveState = .noCompletedSets; return }
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
            errorMessage = String(localized: .uiCouldNotSaveSession)
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
        let total = items[exerciseIndex].sets
        return completedSets.keys.filter { key in
            let parts = key.split(separator: "-")
            guard parts.count == 2, Int(parts[0]) == exerciseIndex, let set = Int(parts[1]) else { return false }
            return set >= 0 && set < total
        }.count
    }
}
