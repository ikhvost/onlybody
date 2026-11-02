/// Produces one recurring notification per scheduled weekday, regardless of session history.
nonisolated struct WorkoutReminderPlanner {
    func requests(for workouts: [WorkoutSnapshot], at time: WorkoutReminderTime) -> [WorkoutReminderRequest] {
        let scheduledDays = Set(workouts.flatMap(\.scheduledDays))
        return Weekdays.shortNames.enumerated().compactMap { index, name in
            guard scheduledDays.contains(name) else { return nil }
            return WorkoutReminderRequest(weekday: index + 1, time: time)
        }
    }
}
