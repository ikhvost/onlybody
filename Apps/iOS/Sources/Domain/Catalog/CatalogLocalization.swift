import Foundation

/// Localizes stable catalog identifiers without changing persisted names or lookup keys.
nonisolated enum CatalogLocalization {
    static func exercise(_ name: String, locale: Locale = .current) -> String {
        guard var resource = ExerciseLocalizationCatalog.resources[name] else { return name }
        resource.locale = locale
        return String(localized: resource)
    }

    static func label(_ name: String, locale: Locale = .current) -> String {
        guard var resource = labels[name] else { return name }
        resource.locale = locale
        return String(localized: resource)
    }

    private static let labels: [String: LocalizedStringResource] = [
        "Chest": .catalogChest,
        "Back": .catalogBack,
        "Shoulders": .catalogShoulders,
        "Biceps": .catalogBiceps,
        "Triceps": .catalogTriceps,
        "Forearms": .catalogForearms,
        "Serratus": .catalogSerratus,
        "Hip Flexors": .catalogHipFlexors,
        "Adductors": .catalogAdductors,
        "Core": .catalogCore,
        "Quads": .catalogQuads,
        "Glutes": .catalogGlutes,
        "Hamstrings": .catalogHamstrings,
        "Calves": .catalogCalves,
        "Full Body": .catalogFullBody,
        "Upper": .catalogUpper,
        "Lower": .catalogLower,
        "All": .catalogAll,
        "None": .catalogNone,
        "Dip Bar": .catalogDipBar,
        "Elevated Surface": .catalogElevatedSurface,
        "Fixed Ankle Support": .catalogFixedAnkleSupport,
        "Low Bar": .catalogLowBar,
        "Pull-up Bar": .catalogPullUpBar,
        "Stable Support": .catalogStableSupport,
        "Towel": .catalogTowel,
        "Wall": .catalogWall,
        "Ab Wheel": .catalogAbWheel,
        "Barbell": .catalogBarbell,
        "Cable Machine": .catalogCableMachine,
        "Chest Press Machine": .catalogChestPressMachine,
        "Dip Belt": .catalogDipBelt,
        "Dumbbells": .catalogDumbbells,
        "EZ-Bar": .catalogEzBar,
        "Flat Bench": .catalogFlatBench,
        "Hack Squat Machine": .catalogHackSquatMachine,
        "Hip Abduction Machine": .catalogHipAbductionMachine,
        "Hip Adduction Machine": .catalogHipAdductionMachine,
        "Incline Bench": .catalogInclineBench,
        "Lat Pulldown Machine": .catalogLatPulldownMachine,
        "Leg Extension Machine": .catalogLegExtensionMachine,
        "Leg Press Machine": .catalogLegPressMachine,
        "Lying Leg Curl Machine": .catalogLyingLegCurlMachine,
        "Pec Deck Machine": .catalogPecDeckMachine,
        "Seated Calf Raise Machine": .catalogSeatedCalfRaiseMachine,
        "Seated Leg Curl Machine": .catalogSeatedLegCurlMachine,
        "Seated Row Machine": .catalogSeatedRowMachine,
        "Squat Rack": .catalogSquatRack,
        "Standing Calf Raise Machine": .catalogStandingCalfRaiseMachine,
        "Step Platform": .catalogStepPlatform,
        "Weight Plates": .catalogWeightPlates,
        "Sun": .catalogSun,
        "Mon": .catalogMon,
        "Tue": .catalogTue,
        "Wed": .catalogWed,
        "Thu": .catalogThu,
        "Fri": .catalogFri,
        "Sat": .catalogSat,
        "Exercise Sliders": .catalogExerciseSliders,
        "Gymnastic Rings": .catalogGymnasticRings,
        "Neutral-Grip Pull-up Bar": .catalogNeutralGripPullUpBar,
        "Suspension Trainer": .catalogSuspensionTrainer,
        "45-Degree Back Extension Bench": .catalog45DegreeBackExtensionBench,
        "Assisted Pull-up and Dip Machine": .catalogAssistedPullUpAndDipMachine,
        "Belt Squat Machine": .catalogBeltSquatMachine,
        "Cable Ankle Strap": .catalogCableAnkleStrap,
        "Captain's Chair": .catalogCaptainSChair,
        "Decline Bench": .catalogDeclineBench,
        "Glute-Ham Developer": .catalogGluteHamDeveloper,
        "Hip Thrust Machine": .catalogHipThrustMachine,
        "Landmine Attachment": .catalogLandmineAttachment,
        "Pendulum Squat Machine": .catalogPendulumSquatMachine,
        "Preacher Curl Bench": .catalogPreacherCurlBench,
        "Reverse Pec Deck Machine": .catalogReversePecDeckMachine,
        "Shoulder Press Machine": .catalogShoulderPressMachine,
        "Smith Machine": .catalogSmithMachine,
        "Trap Bar": .catalogTrapBar,
    ]
}
