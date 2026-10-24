/// Presentation state shared by the details screen and its player callbacks.
nonisolated enum DemonstrationPlaybackState: Equatable {
    case idle
    case offline
    case loading
    case ready
    case playing
    case paused
    case failed(DemonstrationFailure)
}
