/// Controls how generation handles a matching pool that produces fewer than two movements.
nonisolated enum WorkoutFallbackPolicy: Sendable {
    case bodyweight
    case matchingCatalog
}
