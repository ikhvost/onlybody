import XCTest

@MainActor
extension WorkoutJourneyTests {
    func testChangingExerciseResetsSetScrollPosition() {
        createWorkout()
        tap("workout.edit.E2E Workout")
        tap("builder.add")
        let search = app.textFields["exercisePicker.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        dismissKeyboardOutside(search)
        tap("exercise.pick.\(JourneyProduct.libraryExercise)")
        tap("builder.save")
        tap("workout.start.E2E Workout")
        tap("active.start")
        setValue("15", field: "reps", index: 0)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let add = app.buttons["active.set.add"]
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        add.tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        XCTAssertEqual(app.textFields["active.set.1.reps"].value as? String, "15")
        for _ in 0..<6 { add.tap() }
        XCTAssertTrue(app.textFields["active.set.7.reps"].isHittable)
        setValue("9", field: "reps", index: 7)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let remove = app.buttons["active.set.removeLast"]
        for _ in 0..<6 where !remove.isHittable { app.swipeUp() }
        remove.tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        XCTAssertFalse(app.textFields["active.set.7.reps"].exists)
        tap("active.list")
        tap("active.exercise.1")
        // The exercise actions at the top must be visible without scrolling back up.
        XCTAssertTrue(app.buttons["active.guide"].isHittable)
        XCTAssertTrue(app.textFields["active.set.0.reps"].isHittable)
        tap("active.list")
        tap("active.exercise.0")
        XCTAssertTrue(app.buttons["active.guide"].isHittable)
        XCTAssertTrue(app.textFields["active.set.0.reps"].isHittable)
    }
}
