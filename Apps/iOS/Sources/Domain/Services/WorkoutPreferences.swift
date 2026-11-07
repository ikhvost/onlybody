import Observation

/// Shared workout preferences, with persistence supplied by the composition root.
@MainActor
@Observable
final class WorkoutPreferences {
    var isTimerSoundEnabled: Bool {
        didSet {
            guard isTimerSoundEnabled != oldValue else { return }
            saveTimerSound(isTimerSoundEnabled)
        }
    }

    var smartLevel: ExerciseDifficulty { didSet { saveSmartLevel(smartLevel) } }
    private let saveSmartLevel: @MainActor (ExerciseDifficulty) -> Void

    private let saveTimerSound: @MainActor (Bool) -> Void
    private let saveRemindersEnabled: @MainActor (Bool) -> Void
    private let saveReminderTime: @MainActor (WorkoutReminderTime) -> Void
    private let saveWeightUnit: @MainActor (WeightUnit) -> Void

    var weightUnit: WeightUnit {
        didSet {
            guard weightUnit != oldValue else { return }
            saveWeightUnit(weightUnit)
        }
    }

    var areWorkoutRemindersEnabled: Bool {
        didSet {
            guard areWorkoutRemindersEnabled != oldValue else { return }
            saveRemindersEnabled(areWorkoutRemindersEnabled)
        }
    }

    var workoutReminderTime: WorkoutReminderTime {
        didSet {
            guard workoutReminderTime != oldValue else { return }
            saveReminderTime(workoutReminderTime)
        }
    }

    init(
        isTimerSoundEnabled: Bool = true,
        saveTimerSound: @escaping @MainActor (Bool) -> Void = { _ in },
        areWorkoutRemindersEnabled: Bool = false,
        workoutReminderTime: WorkoutReminderTime = WorkoutReminderTime(),
        saveRemindersEnabled: @escaping @MainActor (Bool) -> Void = { _ in },
        saveReminderTime: @escaping @MainActor (WorkoutReminderTime) -> Void = { _ in },
        weightUnit: WeightUnit = .kilograms,
        saveWeightUnit: @escaping @MainActor (WeightUnit) -> Void = { _ in },
        smartLevel: ExerciseDifficulty = .beginner,
        saveSmartLevel: @escaping @MainActor (ExerciseDifficulty) -> Void = { _ in }
    ) {
        self.isTimerSoundEnabled = isTimerSoundEnabled
        self.saveTimerSound = saveTimerSound
        self.areWorkoutRemindersEnabled = areWorkoutRemindersEnabled
        self.workoutReminderTime = workoutReminderTime
        self.saveRemindersEnabled = saveRemindersEnabled
        self.saveReminderTime = saveReminderTime
        self.smartLevel = smartLevel
        self.saveSmartLevel = saveSmartLevel
        self.weightUnit = weightUnit
        self.saveWeightUnit = saveWeightUnit
    }
}
