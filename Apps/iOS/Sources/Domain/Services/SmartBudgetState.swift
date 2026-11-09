/// A partial duration search. The last rest is excluded until another exercise follows it.
nonisolated struct SmartBudgetState: Sendable {
    var movements: [GeneratedMovement] = []
    var seconds = 0
    var preferenceCost = 0

    var key: Int { seconds * 128 + (movements.last?.restSeconds ?? 0) }
}
