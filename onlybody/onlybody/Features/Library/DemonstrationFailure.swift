/// Recoverable failures never prevent viewing or editing the exercise details.
nonisolated enum DemonstrationFailure: Equatable {
    case connection
    case unavailable
    case configuration

    var message: String {
        switch self {
        case .connection: "The video could not load. Check your internet connection and try again."
        case .unavailable: "This video is unavailable here. Try again or open it on YouTube."
        case .configuration: "The video player could not start. Try again or open it on YouTube."
        }
    }

    init(playerError: Int) {
        switch playerError {
        case 100, 101, 150: self = .unavailable
        case 2, 153: self = .configuration
        default: self = .connection
        }
    }
}
