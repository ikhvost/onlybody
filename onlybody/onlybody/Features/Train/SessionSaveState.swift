/// State of the single persisted session produced by an active workout.
enum SessionSaveState {
    case idle
    case saving
    case saved
    case failed
}
