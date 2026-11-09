import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct SmartTargetPolicyTests {
    @Test func presetsReplaceIndividualGroupsAndGroupsReplacePresets() {
        let policy = SmartTargetPolicy()
        for preset in ["Full Body", "Upper", "Lower"] {
            #expect(policy.toggling(preset, in: ["Chest", "Back"]) == [preset])
            #expect(policy.toggling("Shoulders", in: [preset]) == ["Shoulders"])
            #expect(policy.toggling(preset, in: [preset]).isEmpty)
        }
    }

    @Test func fourthGroupCannotBeAddedButSelectionsCanBeRemoved() {
        let policy = SmartTargetPolicy()
        let targets = ["Chest", "Back", "Shoulders"]
        #expect(policy.isValid(targets))
        #expect(!policy.canToggle("Core", in: targets))
        #expect(policy.toggling("Core", in: targets) == targets)
        #expect(policy.toggling("Back", in: targets) == ["Chest", "Shoulders"])
        #expect(policy.canToggle("Full Body", in: targets))
    }

    @Test func invalidStoredSelectionsAreRejectedWithoutTruncation() {
        let policy = SmartTargetPolicy()
        for targets in [[], ["Upper", "Chest"], ["Upper", "Lower"], ["Full Body", "Core"],
                        ["Chest", "Back", "Shoulders", "Core"], ["Chest", "Chest"], ["Unknown"]] {
            #expect(!policy.isValid(targets))
            let result = SmartSelectionGenerator().plan(configuration: SmartWorkoutConfiguration(targetMuscleGroups: targets), from: [])
            #expect(result.status == .unavailable)
            #expect(result.uncoveredNeeds == ["selection"])
        }
    }
}
