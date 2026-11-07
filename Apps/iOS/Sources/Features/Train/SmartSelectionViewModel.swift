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
    var canStart: Bool { variant?.uncoveredNeeds.isEmpty == true && variant?.items.isEmpty == false && !isBusy }
    var targets: [String] { ExerciseCatalog.sessionTargets }
    var equipment: [String] { Array(Set(catalog.flatMap(\.equipment))).filter { $0 != "None" }.sorted() }
    var estimatedMinutes: Int { ((variant?.estimatedSeconds ?? 0) + 59) / 60 }
    var dayLabel: String { (variant?.createdAt ?? now()).formatted(date: .abbreviated, time: .omitted) }
    var gaps: [String] {
        if configuration.targetMuscleGroups.isEmpty { return [String(localized: .uiSelectMuscleGroups)] }
        return (variant?.uncoveredNeeds ?? []).map(SmartNeedLabel.label)
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
        if configuration.targetMuscleGroups.contains(target) {
            configuration.targetMuscleGroups.removeAll { $0 == target }
        } else { configuration.targetMuscleGroups.append(target) }
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
        guard canStart, let settings, let variant, settings.configuration == configuration else { return nil }
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

    func replace(_ itemID: UUID, with exercise: ExerciseSnapshot, confirmingLoads: Bool = false) async {
        guard !isBusy, var daily = variant,
              let index = daily.items.firstIndex(where: { $0.id == itemID }),
              SmartSelectionGenerator().isEligible(exercise, configuration: configuration, ignoringLoads: confirmingLoads) else { return }
        daily.items[index].exercise = exercise
        daily.estimatedSeconds = SmartPrescription().seconds(daily.items)
        daily.uncoveredNeeds = SmartSelectionGenerator().uncoveredNeeds(configuration: configuration, items: daily.items)
        if daily.estimatedSeconds > configuration.durationMinutes * 60 { daily.uncoveredNeeds.append("time") }
        isBusy = true
        defer { isBusy = false }
        do {
            if template.smartSettings?.revision == daily.settingsRevision { try await variants.save(daily) }
            variant = daily
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
