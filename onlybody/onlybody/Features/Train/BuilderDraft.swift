/// Editable values only; loading catalog data never dirties the draft.
struct BuilderDraft: Equatable {
    let name: String
    let mode: WorkoutMode
    let targets: Set<String>
    let movements: [MovementConfig]
    let days: Set<String>

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.mode == rhs.mode && lhs.targets == rhs.targets && lhs.days == rhs.days
            && lhs.movements.elementsEqual(rhs.movements) {
                $0.exercise.id == $1.exercise.id && $0.sets == $1.sets
                    && $0.reps == $1.reps && $0.restSeconds == $1.restSeconds
            }
    }
}
