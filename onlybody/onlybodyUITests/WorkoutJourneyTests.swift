import XCTest

/// Exercises the shipping UI and repositories against a private, seeded file store.
@MainActor
final class WorkoutJourneyTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        await MainActor.run {
            continueAfterFailure = false
            app = XCUIApplication()
            app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
            app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
            app.launchEnvironment["ONLYBODY_DEMONSTRATION_FIXTURE"] = "ready"
            app.launch()
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            if let testRun, testRun.hasSucceeded == false {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.lifetime = .keepAlways
                add(screenshot)
            }
            app.terminate()
        }
    }

    func testCreateSurvivesRelaunch() {
        createWorkout()
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.textFields["builder.name"].value as? String, "E2E Workout")
        XCTAssertTrue(app.staticTexts["1 SETS · 12 REPS · 45S REST"].exists)
    }

    func testEditSurvivesRelaunch() {
        createWorkout()
        tap("workout.edit.E2E Workout")
        tap("stepper.Reps.increase")
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["1 SETS · 13 REPS · 45S REST"].exists)
        tap("builder.add")
        selectExercise()
        tap("builder.save")
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.staticTexts.matching(identifier: "stepper.Sets.value").count, 2)
    }

    func testCompleteWritesOneSession() {
        createWorkout()
        tap("workout.start.E2E Workout")
        tap("active.markSetDone")
        tap("active.close")
        verifyHistory(reps: 12)
        app.terminate()
        app.launch()
        tap("tab.log")
        XCTAssertTrue(app.buttons["session.row"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 1)
    }

    func testEarlyFinishPreservesCompletedSets() {
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("active.markSetDone")
        tap("rest.skip")
        tap("active.end")
        tap("End & Save")
        verifyHistory(reps: 12)
        XCTAssertFalse(app.staticTexts["SET 2 · 12 REPS"].exists)
    }

    func testNavigationAndFullscreenWorkout() {
        createWorkout()
        tap("tab.library")
        tap("difficulty.intermediate")
        XCTAssertTrue(app.descendants(matching: .any)["library.section.intermediate"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["library.section.beginner"].exists)
        tap("difficulty.beginner")
        let search = app.textFields["library.search"]
        search.tap()
        search.typeText("Bird Dog")
        let movement = app.buttons["library.exercise.Bird Dog"]
        XCTAssertTrue(movement.waitForExistence(timeout: 10))
        movement.tap()
        XCTAssertTrue(app.staticTexts["movement.difficulty"].label.contains("Beginner"))
        XCTAssertFalse(app.buttons["Set frequency to More often"].exists)
        XCTAssertFalse(app.buttons["Set frequency to Less often"].exists)
        XCTAssertFalse(app.buttons["Set frequency to Exclude"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["demonstration.preview"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["demonstration.load"].exists)
        XCTAssertTrue(app.staticTexts["demonstration.author"].exists)
        XCTAssertTrue(app.buttons["demonstration.openYouTube"].exists)
        let diagram = app.descendants(matching: .any)["movement.muscleDiagram"]
        XCTAssertTrue(diagram.exists)
        XCTAssertTrue(diagram.label.contains("Muscle groups, front and back views"))
        XCTAssertEqual(app.webViews.count, 0, "The test fixture must not contact YouTube")
        tap("movement.back")
        tap("tab.log")
        tap("tab.train")
        tap("workout.edit.E2E Workout")
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        tap("builder.save")
        tap("workout.start.E2E Workout")
        XCTAssertTrue(app.buttons["active.markSetDone"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        tap("active.end")
        tap("Continue")
        XCTAssertTrue(app.buttons["active.markSetDone"].exists)
        tap("active.end")
        tap("End & Save")
        XCTAssertTrue(app.buttons["tab.train"].waitForExistence(timeout: 10))
    }

    private func createWorkout(sets: Int = 1) {
        tap("workout.create")
        tap("picker.manual")
        let name = app.textFields["builder.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.tap()
        name.typeText("E2E Workout\n")
        tap("builder.add")
        selectExercise()
        for _ in sets..<3 { tap("stepper.Sets.decrease") }
        tap("builder.save")
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
    }

    private func selectExercise() {
        let search = app.textFields["Search movements..."]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText("Standard Push-Ups")
        let exercise = app.buttons["exercise.pick.Standard Push-Ups"]
        // Fixture uses the catalog's exact display name.
        XCTAssertTrue(exercise.waitForExistence(timeout: 10))
        exercise.tap()
    }

    private func verifyHistory(reps: Int) {
        tap("tab.log")
        let row = app.buttons["session.row"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 1)
        row.tap()
        let total = app.staticTexts["session.total.0"]
        XCTAssertTrue(total.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertEqual(total.label, "\(reps) REPS TOTAL")
        XCTAssertEqual(app.staticTexts["session.set.0.0"].label, "SET 1 · \(reps) REPS")
    }

    private func tap(_ identifier: String) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing button: \(identifier)")
        button.tap()
    }
}
