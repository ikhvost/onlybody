import Foundation
import Observation

/// Formats detached historical results using the current display unit without rewriting history.
@MainActor @Observable final class SessionDetailViewModel {
    let session: SessionSnapshot
    private let preferences: WorkoutPreferences
    var items: [SessionItemSnapshot] { session.items.sorted { $0.order < $1.order } }
    var formattedDate: String { session.date.formatted(.dateTime.weekday(.wide).month(.wide).day().locale(.current)) }

    init(session: SessionSnapshot, preferences: WorkoutPreferences = WorkoutPreferences()) {
        self.session = session
        self.preferences = preferences
    }

    func weightText(kilograms: Double?) -> String {
        guard let kilograms else { return "—" }
        return preferences.weightUnit.formatted(kilograms: kilograms)
    }
}
