import Foundation
import Observation

@MainActor
@Observable
final class TrainViewModel {
    private let workoutsRepository: any WorkoutRepository

    var workouts: [WorkoutSnapshot] = []
    var isLoading = false
    var errorMessage: String?

    let appName: String

    let dayNames = Weekdays.shortNames

    var todayIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    var todayName: String {
        dayNames[todayIndex]
    }

    var todaysWorkouts: [WorkoutSnapshot] {
        workouts.filter { $0.scheduledDays.contains(todayName) }
    }

    var dateDisplay: String {
        Date.now.formatted(
            .dateTime
                .weekday(.abbreviated)
                .month(.abbreviated)
                .day()
        ).uppercased()
    }

    init(workouts: any WorkoutRepository, appName: String) {
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
            errorMessage = "Could not load workouts."
        }
    }
}
