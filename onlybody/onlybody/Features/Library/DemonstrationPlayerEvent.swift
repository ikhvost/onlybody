/// Events from the platform player; no WebKit types cross this boundary.
nonisolated enum DemonstrationPlayerEvent {
    case ready
    case playing
    case paused
    case buffering
    case ended
    case failed(DemonstrationFailure)

    init?(playerState: Int) {
        switch playerState {
        case 0: self = .ended
        case 1: self = .playing
        case 2: self = .paused
        case 3: self = .buffering
        case 5: self = .ready
        default: return nil
        }
    }
}
