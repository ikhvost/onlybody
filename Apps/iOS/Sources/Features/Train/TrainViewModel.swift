import Foundation
import Observation

@MainActor
@Observable
final class TrainViewModel {
    private let workoutsRepository: any WorkoutRepository

    var workouts: [WorkoutSnapshot] = []
    var isLoading = false
    var errorMessage: String?

    private let now: () -> Date
    private let calendar: Calendar

    let appName: String

    let dayNames = Weekdays.shortNames

    var todayIndex: Int {
        calendar.component(.weekday, from: now()) - 1
    }

    var todayName: String {
        dayNames[todayIndex]
    }

    var todaysWorkouts: [WorkoutSnapshot] {
        workouts.filter { $0.scheduledDays.contains(todayName) }
    }

    var otherWorkouts: [WorkoutSnapshot] {
        workouts.filter { !$0.scheduledDays.contains(todayName) }
    }

    var dateDisplay: String {
        now().formatted(
            .dateTime
                .weekday(.abbreviated)
                .month(.abbreviated)
                .day()
        )
    }

    init(workouts: any WorkoutRepository, appName: String, now: @escaping () -> Date = Date.init, calendar: Calendar = .current) {
        self.now = now
        self.calendar = calendar
        self.workoutsRepository = workouts
        self.appName = appName
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            workouts = try await workoutsRepository.allWorkouts()
        } catch {
            errorMessage = String(localized: .uiCouldNotLoadWorkouts)
        }
    }
}
