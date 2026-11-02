import Foundation

/// Recoverable failures never prevent viewing or editing the exercise details.
nonisolated enum DemonstrationFailure: Equatable {
    case connection
    case unavailable
    case configuration

    var message: String {
        switch self {
        case .connection: String(localized: .uiTheVideoCouldNotLoadCheckYourInternetConnectionAnd)
        case .unavailable: String(localized: .uiThisVideoIsUnavailableHereTryAgainOrOpenIt)
        case .configuration: String(localized: .uiTheVideoPlayerCouldNotStartTryAgainOrOpen)
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
