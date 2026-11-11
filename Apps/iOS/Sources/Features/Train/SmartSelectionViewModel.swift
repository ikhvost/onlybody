import Foundation
import Observation

/// Owns generation settings and hands a detached daily plan to the shared editor.
@MainActor
@Observable
final class SmartSelectionViewModel {
    private let workouts: any WorkoutRepository
    private let exercises: any ExerciseRepository
    private let variants: any SmartDailyVariantRepository
    private let requestedID: UUID?
    private let now: @MainActor () -> Date
    private var template = WorkoutSnapshot(mode: WorkoutMode.smart.rawValue)
    private var loaded = false
    private var initialConfiguration: SmartWorkoutConfiguration?
    private let opensPreview: Bool
    let offersStandardGym: Bool
    var configuration: SmartWorkoutConfiguration
    private(set) var stage: SmartSelectionStage = .setup
    private(set) var catalog: [ExerciseSnapshot] = []
    private(set) var editorContext: SmartEditorContext?
    private(set) var isBusy = false
    var errorMessage: String?
    var hasUnsavedChanges: Bool { initialConfiguration.map { $0 != configuration } ?? false }
    var hasValidTargets: Bool { SmartTargetPolicy().isValid(configuration.targetMuscleGroups) }
    var targets: [String] { ExerciseCatalog.sessionTargets }
    var equipment: [String] { Array(Set(catalog.flatMap(\.equipment))).filter { $0 != "None" }.sorted() }

    init(workouts: any WorkoutRepository, exercises: any ExerciseRepository, variants: any SmartDailyVariantRepository,
         workoutID: UUID? = nil, targets: [String] = [], equipmentMode: SmartEquipmentMode = .confirmed,
         opensPreview: Bool = false, now: @escaping @MainActor () -> Date = { Date() }) {
        self.workouts = workouts
        self.exercises = exercises
        self.variants = variants
        requestedID = workoutID
        self.now = now
        self.opensPreview = opensPreview
        offersStandardGym = equipmentMode == .standardGym
        configuration = SmartWorkoutConfiguration(targetMuscleGroups: targets, equipmentMode: equipmentMode)
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
                if let settings = existing.smartSettings { configuration = settings.configuration } else {
                    configuration.targetMuscleGroups = existing.targetMuscleGroups
                    configuration.durationMinutes = existing.durationMinutes ?? 30
                }
            }
            initialConfiguration = configuration
            loaded = true
        } catch { errorMessage = String(localized: .uiCouldNotLoadWorkout) }
        isBusy = false
        if loaded, opensPreview { await preview() }
    }

    func retry() async {
        if loaded { await preview() } else { await load() }
    }

    func canToggleTarget(_ target: String) -> Bool {
        SmartTargetPolicy().canToggle(target, in: configuration.targetMuscleGroups)
    }

    func toggleTarget(_ target: String) {
        configuration.targetMuscleGroups = SmartTargetPolicy().toggling(target, in: configuration.targetMuscleGroups)
    }

    func toggleEquipment(_ value: String) {
        if !configuration.availableEquipment.insert(value).inserted { configuration.availableEquipment.remove(value) }
    }

    func removeLegacyLoad(_ value: ExerciseLoad) { configuration.excludedLoads.remove(value) }

    func toggleRegion(_ region: SmartBodyRegion) {
        if !configuration.excludedRegions.insert(region).inserted { configuration.excludedRegions.remove(region) }
    }

    func showConditions() { guard !isBusy, hasValidTargets else { return }; stage = .conditions }
    func edit() { guard !isBusy else { return }; stage = .setup }
    func goBack() { guard !isBusy else { return }; stage = .setup }
    func backFromEditor() { stage = .conditions }

    /// Generation is read-only. Neither opening a day nor cancelling a draft writes to storage.
    func preview() async {
        guard loaded, !isBusy else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            if let editorContext, editorContext.workout.smartSettings?.configuration == configuration {
                stage = .preview
                return
            }
            var settings = template.smartSettings ?? SmartWorkoutSettings(configuration: configuration)
            if settings.configuration != configuration {
                settings.configuration = configuration
                settings.revision = UUID()
                settings.mainExerciseNames = []
            }
            let daily = try await SmartDailyPlanner(variants: variants).resolve(
                workout: template, settings: settings, exercises: catalog, date: now())
            if settings.mainExerciseNames.isEmpty {
                settings.mainExerciseNames = daily.items.compactMap {
                    $0.exercise?.smartMetadata?.role == .main ? $0.exercise?.name : nil
                }
            }
            var workout = template
            workout.mode = WorkoutMode.smart.rawValue
            workout.targetMuscleGroups = configuration.targetMuscleGroups
            workout.durationMinutes = configuration.durationMinutes
            workout.smartSettings = settings
            workout.items = daily.items
            if workout.name.isEmpty { workout.name = String(localized: .smartSmart) }
            editorContext = SmartEditorContext(workout: workout, variant: daily, isExisting: requestedID != nil,
                                               requiresSave: requestedID == nil || workout != template)
            stage = .preview
        } catch { errorMessage = String(localized: .uiCouldNotLoadWorkout) }
    }
}
