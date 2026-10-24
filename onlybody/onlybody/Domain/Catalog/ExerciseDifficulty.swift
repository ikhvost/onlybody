/// Relative strength, balance and coordination demands for the named variation.
nonisolated enum ExerciseDifficulty: String, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
    case unrated

    var label: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        case .unrated: "Unrated"
        }
    }

    static let ratedLevels: [Self] = [.beginner, .intermediate, .advanced]
}
