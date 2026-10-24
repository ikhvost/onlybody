/// Legacy persisted values, retained only to reopen and round-trip existing stores.
/// They are not exposed in the UI and never affect workout generation.
nonisolated enum ExerciseFrequency: String {
    case normal
    case more
    case less
    case never
}
