import Foundation
import Observation

@MainActor
@Observable
final class TrainViewModel {
    private let workoutsRepository: any WorkoutRepository

    var workouts: [Workout] = []
    var isLoading = false
    var errorMessage: String? = nil

    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var todayIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    var todayName: String {
        dayNames[todayIndex]
    }

    var todaysWorkouts: [Workout] {
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

    init(workouts: any WorkoutRepository) {
        self.workoutsRepository = workouts
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
