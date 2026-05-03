enum ExerciseFrequency: String, CaseIterable {
    case normal
    case more
    case less
    case never

    var label: String {
        switch self {
        case .normal:
            "Normal"
        case .more:
            "More often"
        case .less:
            "Less often"
        case .never:
            "Exclude"
        }
    }

    var rank: Int {
        switch self {
        case .more:
            0
        case .normal:
            1
        case .less:
            2
        case .never:
            3
        }
    }
}
