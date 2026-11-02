import Foundation

/// Relative strength, balance and coordination demands for the named variation.
nonisolated enum ExerciseDifficulty: String, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
    case unrated

    var label: String {
        switch self {
        case .beginner: String(localized: .uiBeginner)
        case .intermediate: String(localized: .uiIntermediate)
        case .advanced: String(localized: .uiAdvanced)
        case .unrated: String(localized: .uiUnrated)
        }
    }

    static let ratedLevels: [Self] = [.beginner, .intermediate, .advanced]
}
