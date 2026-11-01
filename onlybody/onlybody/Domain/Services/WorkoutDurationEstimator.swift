/// Shared planning estimate: three seconds per repetition and rest after every set.
nonisolated struct WorkoutDurationEstimator: Sendable {
    func seconds(sets: Int, reps: Int, restSeconds: Int) -> Int {
        guard sets > 0 else { return 0 }
        let work = max(0, reps).multipliedReportingOverflow(by: 3)
        guard !work.overflow else { return Int.max }
        let perSet = adding(max(0, restSeconds), to: work.partialValue)
        let total = max(0, sets).multipliedReportingOverflow(by: perSet)
        return total.overflow ? Int.max : total.partialValue
    }

    func adding(_ seconds: Int, to total: Int) -> Int {
        let sum = total.addingReportingOverflow(seconds)
        return sum.overflow ? Int.max : sum.partialValue
    }

    func budget(minutes: Int) -> Int {
        let seconds = max(0, minutes).multipliedReportingOverflow(by: 60)
        return seconds.overflow ? Int.max : seconds.partialValue
    }
}
