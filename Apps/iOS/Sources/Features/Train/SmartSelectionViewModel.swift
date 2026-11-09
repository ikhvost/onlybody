import Foundation
import Observation

/// Owns an editable draft and the exact daily snapshot handed to the active session.
@MainActor
@Observable
final class SmartSelectionViewModel {
    private let workouts: any WorkoutRepository
    private let exercises: any ExerciseRepository
    private let variants: any SmartDailyVariantRepository
    private let preferences: WorkoutPreferences
    private let requestedID: UUID?
    private let now: @MainActor () -> Date
    private let onScheduleChanged: @MainActor () async -> Void
    private var template = WorkoutSnapshot(mode: WorkoutMode.smart.rawValue)
    private var settings: SmartWorkoutSettings?
    private var loaded = false
    private var savedDraft: SmartSelectionDraft?
    private var returnsToPreview = false
    private let opensPreview: Bool
    let offersStandardGym: Bool
    var configuration: SmartWorkoutConfiguration
    var name = ""
    var scheduledDays: [String] = []
    private(set) var stage: SmartSelectionStage = .setup
    private(set) var catalog: [ExerciseSnapshot] = []
    private(set) var variant: SmartDailyVariant?
    private(set) var isBusy = false
    var errorMessage: String?
    var isExisting: Bool { requestedID != nil || template.smartSettings != nil }
    var assessment: SmartPlanAssessment {
        let currentItems = (variant?.items ?? []).map { item in
            var checked = item
            checked.exercise = catalog.first { $0.name == item.exercise?.name }
            return checked
        }
        return SmartPlanAssessment(configuration: configuration, items: currentItems)
    }
    var canStart: Bool {
        !isBusy && settings?.configuration == configuration
            && variant?.localDay == SmartPlanningClock().localDay(at: now())
            && assessment.status != .unavailable
            && (assessment.status == .complete || variant?.acceptedShortPlan == true)
    }
    var needsShortPlanAcceptance: Bool { assessment.status == .shorter && variant?.acceptedShortPlan != true }
    var hasValidTargets: Bool { SmartTargetPolicy().isValid(configuration.targetMuscleGroups) }
    func canToggleTarget(_ target: String) -> Bool {
        SmartTargetPolicy().canToggle(target, in: configuration.targetMuscleGroups)
    }
    var targets: [String] { ExerciseCatalog.sessionTargets }
    var equipment: [String] { Array(Set(catalog.flatMap(\.equipment))).filter { $0 != "None" }.sorted() }
    var estimatedMinutes: Int { (assessment.estimatedSeconds + 59) / 60 }
    var dayLabel: String { (variant?.createdAt ?? now()).formatted(date: .abbreviated, time: .omitted) }
    var gaps: [String] {
        if configuration.targetMuscleGroups.isEmpty { return [String(localized: .uiSelectMuscleGroups)] }
        return assessment.gaps.map(SmartNeedLabel.label)
    }

    private var draft: SmartSelectionDraft {
        SmartSelectionDraft(configuration: configuration, name: name, scheduledDays: Set(scheduledDays))
    }
    var hasUnsavedChanges: Bool {
        guard let savedDraft else { return false }
        return draft != savedDraft || (requestedID == nil && template.smartSettings == nil && variant != nil)
    }
    var hasPreviousStep: Bool {
        switch stage {
        case .setup: returnsToPreview
        case .conditions: true
        case .preview: !opensPreview
        }
    }

    func showConditions() { guard !isBusy else { return }; stage = .conditions }

    func edit() {
        guard !isBusy else { return }
        returnsToPreview = true
        stage = .setup
    }

    /// Internal back steps retain the draft; leaving the whole flow is handled by the screen.
    func goBack() async {
        guard !isBusy else { return }
        switch stage {
        case .conditions: stage = .setup
        case .preview: if !opensPreview { stage = .conditions }
        case .setup: if returnsToPreview { await preview() }
        }
    }

    init(workouts: any WorkoutRepository, exercises: any ExerciseRepository, variants: any SmartDailyVariantRepository,
         preferences: WorkoutPreferences, workoutID: UUID? = nil, targets: [String] = [],
         equipmentMode: SmartEquipmentMode = .confirmed, opensPreview: Bool = false,
         now: @escaping @MainActor () -> Date = { Date() }, onScheduleChanged: @escaping @MainActor () async -> Void = {}) {
        self.workouts = workouts
        self.exercises = exercises
        self.variants = variants
        self.preferences = preferences
        self.requestedID = workoutID
        self.now = now
        self.onScheduleChanged = onScheduleChanged
        self.opensPreview = opensPreview
        offersStandardGym = equipmentMode == .standardGym
        configuration = SmartWorkoutConfiguration(targetMuscleGroups: targets, level: preferences.smartLevel, equipmentMode: equipmentMode)
    }

    func load() async {
        guard !loaded, !isBusy else { return }
        isBusy = true
        errorMessage = nil
        do {
            catalog = try await exercises.allExercises()
            if let requestedID {
                guard let existing = try await workouts.workout(by: requestedID) else {
                    errorMessage = String(localized: .uiWorkoutNotFound)
                    isBusy = false
                    return
                }
                template = existing
                name = existing.name
                scheduledDays = existing.scheduledDays
                settings = existing.smartSettings
                if let settings { configuration = settings.configuration } else {
                    configuration.targetMuscleGroups = existing.targetMuscleGroups
                    configuration.durationMinutes = existing.durationMinutes ?? 30
                }
            }
            savedDraft = draft
            loaded = true
        } catch { errorMessage = String(localized: .uiCouldNotLoadWorkout) }
        isBusy = false
        if loaded, opensPreview { await preview() }
    }

    func retry() async {
        if loaded { await preview() } else { await load() }
    }

    func toggleTarget(_ target: String) {
        configuration.targetMuscleGroups = SmartTargetPolicy().toggling(target, in: configuration.targetMuscleGroups)
    }

    func toggleEquipment(_ value: String) {
        if !configuration.availableEquipment.insert(value).inserted { configuration.availableEquipment.remove(value) }
    }

    func removeLegacyLoad(_ value: ExerciseLoad) {
        configuration.excludedLoads.remove(value)
    }

    func toggleRegion(_ region: SmartBodyRegion) {
        if !configuration.excludedRegions.insert(region).inserted { configuration.excludedRegions.remove(region) }
    }

    func toggleDay(_ day: String) {
        if scheduledDays.contains(day) { scheduledDays.removeAll { $0 == day } } else { scheduledDays.append(day) }
    }

    func preview() async {
        guard loaded, !isBusy else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            var next = settings ?? SmartWorkoutSettings(configuration: configuration)
            if next.configuration != configuration {
                next.configuration = configuration
                next.revision = UUID()
                next.mainExerciseNames = []
            }
            let daily: SmartDailyVariant
            if let variant, variant.settingsRevision == next.revision, variant.localDay == SmartPlanningClock().localDay(at: now()) {
                daily = variant
            } else {
                daily = try await SmartDailyPlanner(variants: variants).resolve(
                    workout: template, settings: next, exercises: catalog, date: now())
            }
            if next.mainExerciseNames.isEmpty || settings?.configuration != configuration {
                next.mainExerciseNames = daily.items.compactMap { item in
                    guard item.exercise?.smartMetadata?.role == .main else { return nil }
                    return item.exercise?.name
                }
            }
            // Persist a newly opened day only for already-saved, unchanged settings.
            if template.smartSettings?.revision == next.revision { try await variants.save(daily) }
            settings = next
            variant = daily
            returnsToPreview = false
            stage = .preview
        } catch { errorMessage = String(localized: .uiCouldNotSaveSession) }
    }

    /// Foregrounding updates an unopened day; an active session owns a detached copy.
    func refreshDay() async {
        guard stage == .preview, let variant, variant.localDay != SmartPlanningClock().localDay(at: now()) else { return }
        await preview()
    }

    func save() async -> WorkoutSnapshot? {
        guard canStart, let settings, var variant, settings.configuration == configuration else { return nil }
        variant.estimatedSeconds = assessment.estimatedSeconds
        variant.uncoveredNeeds = assessment.gaps
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        var saved = template
        saved.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if saved.name.isEmpty { saved.name = String(localized: .smartSmart) }
        saved.mode = WorkoutMode.smart.rawValue
        saved.targetMuscleGroups = configuration.targetMuscleGroups
        saved.durationMinutes = configuration.durationMinutes
        saved.scheduledDays = scheduledDays
        saved.smartSettings = settings
        saved.items = variant.items
        do {
            try await workouts.save(saved)
            try await variants.save(variant)
            template = saved
            self.variant = variant
            self.settings = settings
            savedDraft = draft
            preferences.smartLevel = configuration.level
            await onScheduleChanged()
            return saved
        } catch {
            errorMessage = String(localized: .uiCouldNotSaveSession)
            return nil
        }
    }

    func replace(_ itemID: UUID, with exercise: ExerciseSnapshot) async {
        guard !isBusy, var daily = variant,
              let index = daily.items.firstIndex(where: { $0.id == itemID }),
              SmartSelectionGenerator().isEligible(exercise, configuration: configuration) else { return }
        daily.items[index].exercise = exercise
        daily.acceptedShortPlan = nil
        await updateDaily(daily)
    }

    func moveMovement(_ id: UUID, to targetID: UUID) async {
        guard !isBusy, var daily = variant,
              let from = daily.items.firstIndex(where: { $0.id == id }),
              let to = daily.items.firstIndex(where: { $0.id == targetID }), from != to else { return }
        daily.items.insert(daily.items.remove(at: from), at: to)
        for index in daily.items.indices { daily.items[index].order = index }
        // The final rest changes when the last exercise changes, so reassess time acceptance.
        if SmartPrescription().seconds(daily.items) != assessment.estimatedSeconds { daily.acceptedShortPlan = nil }
        await updateDaily(daily)
    }

    func acceptShortPlan() async {
        guard !isBusy, needsShortPlanAcceptance, var daily = variant else { return }
        daily.acceptedShortPlan = true
        await updateDaily(daily)
    }

    private func updateDaily(_ daily: SmartDailyVariant) async {
        var updated = daily
        let checked = SmartPlanAssessment(configuration: configuration, items: updated.items)
        updated.estimatedSeconds = checked.estimatedSeconds
        updated.uncoveredNeeds = checked.gaps
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            if template.smartSettings?.revision == updated.settingsRevision { try await variants.save(updated) }
            variant = updated
        } catch { errorMessage = String(localized: .uiCouldNotSaveSession) }
    }

    @discardableResult
    func exclude(_ exercise: ExerciseSnapshot) async -> Bool {
        guard !isBusy else { return false }
        configuration.excludedExercises.insert(exercise.name)
        // This explicit action updates future settings even when no replacement can fill the gap.
        if var savedSettings = template.smartSettings {
            savedSettings.configuration.excludedExercises.insert(exercise.name)
            savedSettings.mainExerciseNames.removeAll { $0 == exercise.name }
            savedSettings.revision = UUID()
            var saved = template
            saved.smartSettings = savedSettings
            isBusy = true
            do {
                try await workouts.save(saved)
                template = saved
                savedDraft = SmartSelectionDraft(configuration: savedSettings.configuration, name: saved.name,
                                                 scheduledDays: Set(saved.scheduledDays))
                settings = savedSettings
                variant = nil
            } catch {
                errorMessage = String(localized: .uiCouldNotSaveSession)
                isBusy = false
                return false
            }
            isBusy = false
        }
        await preview()
        return errorMessage == nil
    }

    func delete() async -> Bool {
        guard isExisting, !isBusy else { return false }
        isBusy = true
        defer { isBusy = false }
        do {
            try await workouts.delete(by: template.id)
            await onScheduleChanged()
            return true
        } catch { errorMessage = String(localized: .uiCouldNotDeleteWorkoutYourTrainingHistoryIsUnchanged); return false }
    }
}
