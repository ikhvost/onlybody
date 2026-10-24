/// Release metadata; legacy persisted fields remain available for lossless store round trips.
nonisolated struct ExerciseMuscleProfile: Sendable, Equatable {
    let primary: [String]
    let secondary: [String]
    let isFullBody: Bool
}
