import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct WorkoutReminderPlannerTests {
    @Test func combinesDaysAndIgnoresDuplicatesAndUnknownNames() {
        let workouts = [
            WorkoutSnapshot(scheduledDays: ["Sun", "Mon", "Mon", "unknown"]),
            WorkoutSnapshot(scheduledDays: ["Mon", "Sat", "sun"])
        ]
        let requests = WorkoutReminderPlanner().requests(for: workouts, at: WorkoutReminderTime(minutes: 795))
        #expect(requests.map(\.weekday) == [1, 2, 7])
        #expect(Set(requests.map(\.identifier)).count == 3)
        #expect(requests.allSatisfy { $0.time.hour == 13 && $0.time.minute == 15 })
    }

    @Test func allWeekdaysHaveStableUniqueIdentifiers() {
        let requests = WorkoutReminderPlanner().requests(
            for: [WorkoutSnapshot(scheduledDays: Weekdays.shortNames)], at: WorkoutReminderTime()
        )
        #expect(requests.map(\.weekday) == Array(1...7))
        #expect(requests.map(\.identifier) == WorkoutReminderRequest.identifiers)
        #expect(WorkoutReminderPlanner().requests(for: [], at: WorkoutReminderTime()).isEmpty)
        #expect(WorkoutReminderPlanner().requests(for: [WorkoutSnapshot()], at: WorkoutReminderTime()).isEmpty)
    }

    @Test func timeGridIncludesMidnightAndLastQuarterHour() {
        #expect(WorkoutReminderTime.options.count == 96)
        #expect(WorkoutReminderTime.options.first?.label == "00:00")
        #expect(WorkoutReminderTime.options.last?.label == "23:45")
        #expect(WorkoutReminderTime().label == "13:00")
        #expect(WorkoutReminderTime(minutes: 795).label == "13:15")
        #expect(WorkoutReminderTime(minutes: 810).label == "13:30")
    }

    @Test(arguments: [-1, 1, 1440, 9999])
    func invalidStoredTimeFallsBackToOnePM(minutes: Int) {
        #expect(WorkoutReminderTime(minutes: minutes).label == "13:00")
    }
}
