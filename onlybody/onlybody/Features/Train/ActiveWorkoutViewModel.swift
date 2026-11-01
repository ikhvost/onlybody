import Foundation
import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let sessionsRepository: any SessionRepository
    private let exercisesRepository: (any ExerciseRepository)?
    private let preferences: WorkoutPreferences
    private let alwaysShowsWeight: Bool
    private let time: any WorkoutTimeSource
    private let stopRestCue: @MainActor () -> Void
    private var startedAt: Date?
    private var finishedAt: Date?
    private var hasLoaded = false
    private var isDiscarded = false
    private let sessionID = UUID()
    private var elapsedTask: Task<Void, Never>?
    private var rows: [WorkoutSetID: WorkoutSetDraft] = [:]
    private var revealedWeightExercises: Set<UUID> = []

    let workoutId: UUID
    let restTimer: RestTimer
    private(set) var workoutName = ""
    private(set) var items: [WorkoutItemSnapshot] = []
    private(set) var currentItemID: UUID?
    private(set) var viewedItemID: UUID?
    private(set) var hasStarted = false
    private(set) var showsExerciseList = true
    private(set) var isComplete = false
    private(set) var isLoading = false
    private(set) var elapsedSeconds = 0
    private(set) var saveState: SessionSaveState = .idle
    private(set) var saveTask: Task<Void, Never>?
    var errorMessage: String?
    private(set) var allExercises: [ExerciseSnapshot] = []
    private(set) var isLoadingExercises = false
    var replacementError: String?

    var currentItem: WorkoutItemSnapshot? { items.first { $0.id == viewedItemID } }
    var currentExerciseIndex: Int { items.firstIndex { $0.id == viewedItemID } ?? 0 }
    var currentExerciseName: String { currentItem?.exercise?.name ?? "" }
    var currentSetsTotal: Int { currentItem?.sets ?? 0 }
    var currentTargetReps: Int { currentItem?.targetReps ?? 0 }
    var currentSetIndex: Int {
        guard let item = currentItem else { return 0 }
        var index = 0
        let completed = Set(rows.filter { $0.key.itemID == item.id && $0.value.isDone }.map { $0.key.index })
        while completed.contains(index) { index += 1 }
        return min(index, max(0, item.sets - 1))
    }
    var currentKey: WorkoutSetID { WorkoutSetID(itemID: viewedItemID ?? workoutId, index: currentSetIndex) }
    var completedSets: [WorkoutSetID: Int] { rows.filter { $0.value.isDone }.mapValues(\.reps) }
    var completedSetCount: Int { rows.values.filter(\.isDone).count }
    var completedSetsForCurrent: Int { completedCount(for: viewedItemID) }
    var allSetsCompleted: Bool { !items.isEmpty && items.allSatisfy { completedCount(for: $0.id) == $0.sets } }
    var hasInvalidNumbers: Bool { rows.values.contains { $0.invalidReps || $0.invalidWeight } }
    var canClose: Bool { saveState == .saved || saveState == .noCompletedSets }
    var canEdit: Bool { !isComplete && !isDiscarded && saveState == .idle }
    var showsWeight: Bool { alwaysShowsWeight || viewedItemID.map { revealedWeightExercises.contains($0) } == true }
    var isRestActive: Bool { restTimer.isActive }
    var remainingRestSeconds: Int { restTimer.remainingSeconds }
    func extendRest() { restTimer.add(seconds: 15) }
    func skipRest() { stopRestCue(); restTimer.skip() }
    var weightUnitSymbol: String { preferences.weightUnit.rawValue }
    var currentWeight: Double { row(currentKey).weightKg }
    var displayedWeight: Double { preferences.weightUnit.value(fromKilograms: currentWeight) }
    var currentDisplayReps: Int { row(currentKey).reps }

    init(
        workouts: any WorkoutRepository, sessions: any SessionRepository, workoutId: UUID,
        exercises: (any ExerciseRepository)? = nil,
        time: any WorkoutTimeSource = SystemWorkoutTimeSource(), preferences: WorkoutPreferences = WorkoutPreferences(),
        alwaysShowsWeight: Bool = false, playRestCue: @escaping @MainActor () -> Void = {},
        stopRestCue: @escaping @MainActor () -> Void = {}
    ) {
        self.workoutsRepository = workouts
        self.sessionsRepository = sessions
        self.exercisesRepository = exercises
        self.workoutId = workoutId
        self.time = time
        self.preferences = preferences
        self.alwaysShowsWeight = alwaysShowsWeight
        self.restTimer = RestTimer(time: time) { if preferences.isTimerSoundEnabled { playRestCue() } }
        self.stopRestCue = stopRestCue
    }

    func load() async {
        guard !isLoading, !hasLoaded else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let workout = try await workoutsRepository.workout(by: workoutId) else {
                errorMessage = String(localized: .uiWorkoutNotFound)
                return
            }
            workoutName = workout.name
            items = workout.items.sorted { $0.order < $1.order }
            guard !items.isEmpty else { errorMessage = String(localized: .uiWorkoutHasNoExercises); return }
            viewedItemID = items.first?.id
            hasLoaded = true
        } catch { errorMessage = String(localized: .uiCouldNotLoadWorkout) }
    }

    func beginSession() {
        guard hasLoaded, !hasStarted, canEdit else { return }
        hasStarted = true
        currentItemID = items.first?.id
        viewedItemID = currentItemID
        showsExerciseList = false
        startedAt = time.now
        startElapsedTimer()
    }

    func showExercise(_ id: UUID) {
        guard canEdit, !hasInvalidNumbers, items.contains(where: { $0.id == id }) else { return }
        viewedItemID = id
        showsExerciseList = false
    }

    func showList() {
        guard !hasInvalidNumbers else { return }
        showsExerciseList = true
    }

    func resume() { if let currentItemID { showExercise(currentItemID) } }

    func row(_ id: WorkoutSetID) -> WorkoutSetDraft {
        rows[id] ?? WorkoutSetDraft(reps: items.first { $0.id == id.itemID }?.targetReps ?? 0)
    }

    func repsText(for id: WorkoutSetID) -> String { row(id).repsInput ?? String(row(id).reps) }
    func weightText(for id: WorkoutSetID) -> String {
        row(id).weightInput ?? preferences.weightUnit.value(fromKilograms: row(id).weightKg)
            .formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
    }

    func enterReps(_ text: String, for id: WorkoutSetID? = nil) {
        let key = id ?? currentKey
        guard canEdit, contains(key) else { return }
        var draft = row(key)
        draft.repsInput = text
        if let value = WorkoutNumberParser().integer(text, minimum: 0) { draft.reps = value; draft.invalidReps = false } else { draft.invalidReps = true }
        rows[key] = draft
    }

    func enterWeight(_ text: String, for id: WorkoutSetID? = nil, locale: Locale = .current) {
        let key = id ?? currentKey
        guard canEdit, contains(key) else { return }
        var draft = row(key)
        draft.weightInput = text
        if let value = WorkoutNumberParser().weight(text, locale: locale) {
            draft.weightKg = preferences.weightUnit.kilograms(from: value)
            draft.invalidWeight = false
        } else { draft.invalidWeight = true }
        rows[key] = draft
        revealedWeightExercises.insert(key.itemID)
    }

    func revealWeight() { if let viewedItemID { revealedWeightExercises.insert(viewedItemID) } }

    func completedCount(for id: UUID?) -> Int { rows.filter { $0.key.itemID == id && $0.value.isDone }.count }
    func canReplace(_ id: UUID) -> Bool { canEdit && completedCount(for: id) == 0 }

    func moveExercise(_ id: UUID, to targetID: UUID) {
        guard canEdit, !hasInvalidNumbers, let from = items.firstIndex(where: { $0.id == id }),
              let to = items.firstIndex(where: { $0.id == targetID }), from != to else { return }
        items.insert(items.remove(at: from), at: to)
        for index in items.indices { items[index].order = index }
    }

    func replaceExercise(_ id: UUID, with exercise: ExerciseSnapshot) {
        guard canReplace(id), !hasInvalidNumbers, let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].exercise = exercise
        rows = rows.filter { $0.key.itemID != id }
        revealedWeightExercises.remove(id)
    }

    func loadReplacementExercises() async {
        guard !isLoadingExercises else { return }
        isLoadingExercises = true
        replacementError = nil
        defer { isLoadingExercises = false }
        do { allExercises = try await exercisesRepository?.allExercises() ?? [] } catch { replacementError = String(localized: .uiCouldNotLoadExercises) }
    }

    func toggleSet(_ id: WorkoutSetID) {
        guard hasStarted, canEdit, !hasInvalidNumbers, contains(id),
              let item = items.first(where: { $0.id == id.itemID }) else { return }
        var draft = row(id)
        draft.isDone.toggle()
        rows[id] = draft
        if draft.isDone {
            stopRestCue()
            restTimer.start(seconds: item.restSeconds)
            if currentItemID == id.itemID, completedCount(for: item.id) == item.sets { advance(after: item.id) }
        }
        if currentItemID == nil, !allSetsCompleted { currentItemID = items.first { completedCount(for: $0.id) < $0.sets }?.id }
        if allSetsCompleted { showsExerciseList = true }
    }

    private func advance(after id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let order = Array(items.dropFirst(index + 1)) + Array(items.prefix(index))
        currentItemID = order.first { completedCount(for: $0.id) < $0.sets }?.id
        if let currentItemID { viewedItemID = currentItemID }
    }

    private func contains(_ id: WorkoutSetID) -> Bool {
        items.contains { $0.id == id.itemID && id.index >= 0 && id.index < $0.sets }
    }

    func buildSessionItems() -> [SessionItemSnapshot] {
        items.enumerated().map { index, item in
            let completed = rows.filter { $0.key.itemID == item.id && $0.value.isDone }.sorted { $0.key.index < $1.key.index }
            return SessionItemSnapshot(order: index, exerciseName: item.exercise?.name ?? "", plannedSets: item.sets,
                                       plannedReps: item.targetReps, setReps: completed.map { $0.value.reps },
                                       weightKg: completed.last?.value.weightKg ?? 0,
                                       setWeightsKg: completed.map { $0.value.weightKg })
        }
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
        guard hasStarted, !items.isEmpty, !isDiscarded, !hasInvalidNumbers else { return }
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

}
