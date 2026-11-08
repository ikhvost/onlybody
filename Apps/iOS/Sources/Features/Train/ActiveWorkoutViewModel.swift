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
    private let restAlerts: WorkoutRestAlerts
    private let liveActivity: (any WorkoutLiveActivity)?
    private var restOrigin: WorkoutSetID?
    private var restStartedAt: Date?
    private var startedAt: Date?
    private var finishedAt: Date?
    private var hasLoaded = false
    private var isDiscarded = false
    private let sessionID = UUID()
    private var elapsedTask: Task<Void, Never>?
    private var rows: [WorkoutSetID: WorkoutSetDraft] = [:]
    private var previousPerformances: [String: [SessionItemSnapshot]] = [:]
    private var previousOccurrence: [UUID: Int] = [:]
    private(set) var historyErrorMessage: String?
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
        return firstIncompleteSet(for: item) ?? max(0, item.sets - 1)
    }
    var currentKey: WorkoutSetID { WorkoutSetID(itemID: viewedItemID ?? workoutId, index: currentSetIndex) }
    var completedSets: [WorkoutSetID: Int] { rows.filter { $0.value.isDone }.mapValues(\.reps) }
    var completedSetCount: Int { rows.values.filter(\.isDone).count }
    var completedSetsForCurrent: Int { completedCount(for: viewedItemID) }
    var allSetsCompleted: Bool { !items.isEmpty && items.allSatisfy { completedCount(for: $0.id) == $0.sets } }
    var hasInvalidNumbers: Bool { rows.values.contains { $0.invalidReps || $0.invalidWeight } }
    var canClose: Bool { saveState == .saved || saveState == .noCompletedSets }
    var canEdit: Bool { !isComplete && !isDiscarded && saveState == .idle }
    var showsWeight: Bool {
        if alwaysShowsWeight || viewedItemID.map({ revealedWeightExercises.contains($0) }) == true { return true }
        guard let previous = currentItem.flatMap({ previousPerformance(for: $0) }) else { return false }
        return previous.setWeightsKg?.contains(where: { $0 > 0 }) == true || (previous.weightKg ?? 0) > 0
    }
    var isRestActive: Bool { restTimer.isActive }
    var remainingRestSeconds: Int { restTimer.remainingSeconds }
    func extendRest() {
        restTimer.add(seconds: 15)
        guard let deadline = restTimer.deadline else { return }
        restAlerts.setDeadline(deadline)
        publishActivity()
    }

    func skipRest() {
        cancelRest()
        publishActivity()
    }

    func synchronizeRest() { restTimer.synchronize() }
    var weightUnitSymbol: String { preferences.weightUnit.rawValue }
    var currentWeight: Double { row(currentKey).weightKg }
    var displayedWeight: Double { preferences.weightUnit.value(fromKilograms: currentWeight) }
    var currentDisplayReps: Int { row(currentKey).reps }

    init(
        workouts: any WorkoutRepository, sessions: any SessionRepository, workoutId: UUID,
        exercises: (any ExerciseRepository)? = nil,
        time: any WorkoutTimeSource = SystemWorkoutTimeSource(), preferences: WorkoutPreferences = WorkoutPreferences(),
        alwaysShowsWeight: Bool = false, restAlerts: WorkoutRestAlerts? = nil,
        liveActivity: (any WorkoutLiveActivity)? = nil
    ) {
        self.workoutsRepository = workouts
        self.sessionsRepository = sessions
        self.exercisesRepository = exercises
        self.workoutId = workoutId
        self.time = time
        self.preferences = preferences
        self.alwaysShowsWeight = alwaysShowsWeight
        self.restAlerts = restAlerts ?? WorkoutRestAlerts(time: time, isEnabled: { preferences.isTimerSoundEnabled })
        self.liveActivity = liveActivity
        self.restTimer = RestTimer(time: time)
        restTimer.onFinished = { [weak self] in self?.restDidFinish() }
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
            var occurrences: [String: Int] = [:]
            for item in items {
                let name = item.exercise?.name ?? ""
                previousOccurrence[item.id] = occurrences[name, default: 0]
                occurrences[name, default: 0] += 1
            }
            guard !items.isEmpty else { errorMessage = String(localized: .uiWorkoutHasNoExercises); return }
            viewedItemID = items.first?.id
            await loadPreviousPerformances()
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
        liveActivity?.start(sessionID: sessionID, workoutName: workoutName, state: activityState())
        restAlerts.prepare()
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
        if let edited = rows[id] { return edited }
        guard let item = items.first(where: { $0.id == id.itemID }) else { return WorkoutSetDraft(reps: 0) }
        guard let previous = previousPerformance(for: item), !previous.setReps.isEmpty else {
            return WorkoutSetDraft(reps: item.targetReps)
        }
        let index = min(max(0, id.index), previous.setReps.count - 1)
        return WorkoutSetDraft(reps: previous.setReps[index], weightKg: previous.weightForSet(at: index) ?? previous.weightKg ?? 0)
    }

    /// Retrying history loading changes only untouched rows; edits and completion stay in `rows`.
    func loadPreviousPerformances() async {
        do {
            previousPerformances = LatestExercisePerformances().items(in: try await sessionsRepository.allSessions())
            historyErrorMessage = nil
        } catch {
            historyErrorMessage = String(localized: .uiCouldNotLoadExerciseHistory)
        }
    }

    private func previousPerformance(for item: WorkoutItemSnapshot) -> SessionItemSnapshot? {
        guard let name = item.exercise?.name, let previous = previousPerformances[name], !previous.isEmpty else { return nil }
        let occurrence = previousOccurrence[item.id] ?? 0
        return previous[min(occurrence, previous.count - 1)]
    }

    func repsText(for id: WorkoutSetID) -> String { row(id).repsInput ?? String(row(id).reps) }
    func weightText(for id: WorkoutSetID) -> String {
        row(id).weightInput ?? preferences.weightUnit.value(fromKilograms: row(id).weightKg)
            .formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
    }

    /// Replace a pristine zero on focus without changing its committed numeric value.
    func beginWeightEditing(_ id: WorkoutSetID) {
        guard canEdit, contains(id) else { return }
        var draft = row(id)
        guard draft.weightKg == 0, !draft.invalidWeight else { return }
        draft.weightInput = ""
        draft.isReplacingInitialZero = true
        rows[id] = draft
    }

    /// An untouched zero is restored; a user-cleared invalid value remains editable.
    func endWeightEditing(_ id: WorkoutSetID) {
        guard var draft = rows[id], draft.isReplacingInitialZero else { return }
        draft.isReplacingInitialZero = false
        draft.weightInput = nil
        draft.invalidWeight = false
        rows[id] = draft
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
        // TextField can echo the programmatic clearing before the first keystroke.
        if draft.isReplacingInitialZero, text.isEmpty { return }
        draft.isReplacingInitialZero = false
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
        previousOccurrence[id] = 0
        rows = rows.filter { $0.key.itemID != id }
        revealedWeightExercises.remove(id)
        publishActivity()
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
            if currentItemID == id.itemID, completedCount(for: item.id) == item.sets { advance(after: item.id) }
            if allSetsCompleted {
                cancelRest()
                showsExerciseList = true
            } else {
                startRest(after: id, seconds: item.restSeconds)
            }
        } else if restOrigin == id {
            cancelRest()
        }
        if currentItemID == nil, !allSetsCompleted { currentItemID = items.first { completedCount(for: $0.id) < $0.sets }?.id }
        publishActivity()
    }

    private func startRest(after id: WorkoutSetID, seconds: Int) {
        restTimer.start(seconds: seconds)
        restOrigin = restTimer.isActive ? id : nil
        restStartedAt = restTimer.deadline?.addingTimeInterval(-TimeInterval(seconds))
        restAlerts.setDeadline(restTimer.deadline)
    }

    private func cancelRest() {
        restTimer.skip()
        restOrigin = nil
        restStartedAt = nil
        restAlerts.setDeadline(nil)
    }

    private func restDidFinish() {
        restStartedAt = nil
        restAlerts.restDidFinish()
        publishActivity()
    }

    private func firstIncompleteSet(for item: WorkoutItemSnapshot) -> Int? {
        guard item.sets > 0 else { return nil }
        return (0..<item.sets).first { rows[WorkoutSetID(itemID: item.id, index: $0)]?.isDone != true }
    }

    private func activityState() -> WorkoutActivityState {
        let item = items.first { $0.id == currentItemID }
        let setNumber = item.flatMap { firstIncompleteSet(for: $0) }.map { $0 + 1 }
        let name = item?.exercise.map { String($0.displayName.prefix(100)) }
        return WorkoutActivityState(
            exerciseName: name, setNumber: setNumber, totalSets: item?.sets, allSetsCompleted: allSetsCompleted,
            restStartedAt: restStartedAt, restDeadline: restTimer.deadline
        )
    }

    private func publishActivity() {
        guard hasStarted, canEdit, let liveActivity else { return }
        liveActivity.update(activityState())
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
        elapsedTask?.cancel()
        if hasStarted {
            cancelRest()
            liveActivity?.end()
        }
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
        isComplete = true
        finishTiming()
        cancelRest()
        liveActivity?.end()
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
