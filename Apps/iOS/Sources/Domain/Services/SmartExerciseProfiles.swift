import Foundation

/// Selection-only profiles. Does not change the exercise catalog or persisted exercise records.
/// Holds and carries remain available in the library; v1 selects repetition-based movements only.
nonisolated enum SmartExerciseProfiles {
    static let entries: [String: SmartExerciseMetadata] = [
        "Wall Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .standing]),
        "Incline Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Knee Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport]),
        "Standard Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Decline Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Archer Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Superman": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "back-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Prone Y Raises": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "scapular",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Reverse Snow Angels": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "scapular",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Inverted Rows": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Foot-Assisted Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Negative Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Chin-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Archer Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Pike Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .overhead]),
        "Feet-Elevated Pike Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .overhead]),
        "Wall Handstand Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .overhead]),
        "Foot-Assisted Dips": SmartExerciseMetadata(
            movement: .push, role: .main, family: "dip",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Diamond Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Dips": SmartExerciseMetadata(
            movement: .push, role: .main, family: "dip",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Dead Bug": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-dead-bug",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Reverse Crunch": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-crunch",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Hanging Leg Raises": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hanging",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Assisted Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Split Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Reverse Lunges": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Step-Ups": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Bulgarian Split Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Assisted Pistol Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Cossack Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Pistol Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Glute Bridge": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Side-Lying Hip Abduction": SmartExerciseMetadata(
            movement: .abduction, role: .accessory, family: "hip-abduction",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Single-Leg Glute Bridge": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Single-Leg Hip Thrusts": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Single-Leg Romanian Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Hamstring Walkouts": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Sliding Leg Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Nordic Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.kneeSupport]),
        "Calf Raises": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Single-Leg Calf Raises": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Walking Jacks": SmartExerciseMetadata(
            movement: .locomotion, role: .accessory, family: "locomotion",
            repetitionRule: .fullCycle, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Jumping Jacks": SmartExerciseMetadata(
            movement: .locomotion, role: .accessory, family: "locomotion",
            repetitionRule: .fullCycle, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.jumping, .standing]),
        "Mountain Climbers": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-mountain-climbers",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Burpees": SmartExerciseMetadata(
            movement: .locomotion, role: .accessory, family: "locomotion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.jumping, .palmSupport, .standing]),
        "Scapular Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Scapular Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "scapular",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Close-Grip Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Bird Dog": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-bird-dog",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport]),
        "Bicycle Crunches": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-crunch",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Flutter Kicks": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-leg-raise",
            repetitionRule: .fullCycle, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Hanging Knee Raises": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hanging",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Lateral Lunges": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Jump Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.jumping, .standing]),
        "Donkey Kicks": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "hip-kickback",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport]),
        "Fire Hydrants": SmartExerciseMetadata(
            movement: .abduction, role: .accessory, family: "hip-abduction",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport]),
        "Bear Crawl": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-bear-crawl",
            repetitionRule: .fullCycle, repetitionSeconds: 6, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "High Knees": SmartExerciseMetadata(
            movement: .locomotion, role: .accessory, family: "locomotion",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.jumping, .standing]),
        "Bent-Knee Calf Raises": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-seated",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Wide Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Hand-Release Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Ring Push-Ups": SmartExerciseMetadata(
            movement: .push, role: .main, family: "push-up",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Bar Bodyweight Triceps Extensions": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "elbow-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Neutral-Grip Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.overhead]),
        "Bent-Knee Inverted Rows": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Feet-Elevated Inverted Rows": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Ring Rows": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Ring Biceps Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Bodyweight Box Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Heel-Elevated Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Walking Lunges": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Front-Foot-Elevated Split Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Lateral Step-Ups": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Bodyweight Good Mornings": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Skater Squats": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Reverse Nordic Curls": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "knee-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.kneeSupport]),
        "Bodyweight Hip Thrusts": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Long-Lever Glute Bridge": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Single-Leg Sliding Leg Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Hand-Assisted Nordic Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport]),
        "Suspension Hamstring Curls": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Single-Leg Calf Raises on a Step": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Wall Tibialis Raises": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "ankle-dorsiflexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.standing]),
        "Crunches": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-crunch",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Lying Leg Raises": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-leg-raise",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Side Plank Hip Lifts": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-plank",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Plank Shoulder Taps": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-plank",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Plank Up-Downs": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-plank",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: [.palmSupport]),
        "Hollow Body Rocks": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hollow-body-rocks",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 10, transitionSeconds: 20, loads: []),
        "Barbell Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Incline Dumbbell Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Lat Pulldown": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Seated Cable Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Dumbbell Shoulder Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Dumbbell Lateral Raise": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "shoulder-abduction",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Cable Face Pull": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "scapular",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Cable Triceps Pushdown": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "elbow-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Barbell Back Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Leg Press": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Barbell Romanian Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Leg Extension": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "knee-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Seated Leg Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Standing Calf Raise": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Cable Crunch": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-crunch",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.kneeSupport]),
        "Incline Barbell Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Dumbbell Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Dumbbell Fly": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "chest-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Cable Chest Fly": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "chest-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Machine Chest Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Pec Deck Fly": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "chest-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Barbell Bent-Over Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "One-Arm Dumbbell Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.palmSupport, .kneeSupport, .standing]),
        "Chest-Supported Dumbbell Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Straight-Arm Cable Pulldown": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "pullover",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Weighted Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Weighted Chin-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Barbell Overhead Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead, .standing]),
        "Arnold Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Cable Lateral Raise": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "shoulder-abduction",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Reverse Fly": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "reverse-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Barbell Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "EZ-Bar Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Hammer Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Incline Dumbbell Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Cable Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Overhead Cable Triceps Extension": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "elbow-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead, .standing]),
        "EZ-Bar Skull Crusher": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "elbow-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Close-Grip Barbell Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Weighted Dips": SmartExerciseMetadata(
            movement: .push, role: .main, family: "dip",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Barbell Front Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Barbell Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Sumo Barbell Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Goblet Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Bulgarian Split Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Reverse Lunge": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Walking Lunge": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Step-Up": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Romanian Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Barbell Hip Thrust": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Hack Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Lying Leg Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Hip Abduction Machine": SmartExerciseMetadata(
            movement: .abduction, role: .accessory, family: "hip-abduction",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Hip Adduction Machine": SmartExerciseMetadata(
            movement: .adduction, role: .accessory, family: "hip-adduction",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Seated Calf Raise": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-seated",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Hanging Knee Raise": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hanging",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Hanging Leg Raise": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hanging",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Ab Wheel Rollout": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-ab-wheel-rollout",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.kneeSupport]),
        "Cable Woodchop": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-cable-woodchop",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Machine Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Barbell Upright Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "upright-row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Floor Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Decline Barbell Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Incline Dumbbell Fly": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "chest-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Low-to-High Cable Fly": SmartExerciseMetadata(
            movement: .push, role: .accessory, family: "chest-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Smith Machine Incline Bench Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "chest-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Neutral-Grip Lat Pulldown": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Single-Arm Cable Lat Pulldown": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Single-Arm Cable Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Landmine Row": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "row",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Machine-Assisted Pull-Ups": SmartExerciseMetadata(
            movement: .pull, role: .main, family: "vertical-pull",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Dumbbell Pullover": SmartExerciseMetadata(
            movement: .pull, role: .accessory, family: "pullover",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Weighted 45-Degree Back Extension": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Machine Shoulder Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead]),
        "Half-Kneeling Landmine Press": SmartExerciseMetadata(
            movement: .push, role: .main, family: "overhead-press",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.kneeSupport, .overhead]),
        "Reverse Pec Deck": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "reverse-fly",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "EZ-Bar Preacher Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Concentration Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "elbow-flexion",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Reverse EZ-Bar Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "reverse-curl",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Two-Hand Dumbbell Overhead Triceps Extension": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "elbow-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.overhead, .standing]),
        "Machine-Assisted Dips": SmartExerciseMetadata(
            movement: .push, role: .main, family: "dip",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Double-Dumbbell Front Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Split Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Lateral Lunge": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "lunge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Smith Machine Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Belt Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Pendulum Squat": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Single-Leg Press": SmartExerciseMetadata(
            movement: .squat, role: .main, family: "squat",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Trap Bar Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Single-Leg Dumbbell Romanian Deadlift": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Barbell Good Morning": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-hinge",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Cable Glute Kickback": SmartExerciseMetadata(
            movement: .extension, role: .accessory, family: "hip-kickback",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Hip Thrust": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Hip Thrust Machine": SmartExerciseMetadata(
            movement: .hinge, role: .main, family: "hip-extension",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Single-Leg Seated Leg Curl": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Glute-Ham Raise": SmartExerciseMetadata(
            movement: .curl, role: .accessory, family: "knee-flexion",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Leg Press Calf Raise": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Single-Leg Dumbbell Calf Raise": SmartExerciseMetadata(
            movement: .calf, role: .accessory, family: "calf-standing",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Dumbbell Shrug": SmartExerciseMetadata(
            movement: .raise, role: .accessory, family: "shrug",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Pallof Press": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-pallof-press",
            repetitionRule: .perSide, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: [.standing]),
        "Weighted Crunch": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-crunch",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
        "Captain Chair Knee Raise": SmartExerciseMetadata(
            movement: .core, role: .accessory, family: "core-hanging",
            repetitionRule: .total, repetitionSeconds: 3, setupSeconds: 20, transitionSeconds: 20, loads: []),
    ]
}
