import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

/// Sequential actions keep timing, cue, and persistence regression tests concise.
@MainActor
extension ActiveWorkoutViewModel {
    func markSetDone() { toggleSet(currentKey) }
    func incrementReps() { enterReps(String(currentDisplayReps + 1)) }
    func incrementWeight() {
        let step = weightUnitSymbol == "lb" ? 5.0 : 2.5
        enterWeight((displayedWeight + step).formatted(.number.grouping(.never)), locale: .current)
    }
    func decrementWeight() { enterWeight("0") }
}
