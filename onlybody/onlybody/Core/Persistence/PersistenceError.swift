/// A referenced catalog entry disappeared before the workout could be saved.
enum PersistenceError: Error {
    case exerciseUnavailable
}
