import Foundation
import Observation

@MainActor
@Observable
final class SessionDetailViewModel {
    let session: Session

    var workoutName: String {
        session.workoutName
    }

    var dateLabel: String {
        session.date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.wide)
                .day()
                .locale(Locale(identifier: "en_US"))
        ).uppercased()
    }

    var durationValue: String {
        Duration.seconds(session.durationSeconds)
            .formatted(.time(pattern: .minuteSecond))
    }

    var durationUnit: String {
        "min"
    }

    var caloriesValue: String {
        if let cals = session.caloriesBurned {
            return "\(cals)"
        }
        return "\u{2014}"
    }

    var caloriesUnit: String {
        session.caloriesBurned != nil ? "kcal" : ""
    }

    var sortedItems: [SessionItem] {
        (session.items ?? []).sorted { $0.order < $1.order }
    }

    init(session: Session) {
        self.session = session
    }

    func totalReps(for item: SessionItem) -> Int {
        item.setReps.reduce(0, +)
    }

    func setLabel(index: Int, reps: Int) -> String {
        "SET \(index + 1) \u{00B7} \(reps) REPS"
    }
}
