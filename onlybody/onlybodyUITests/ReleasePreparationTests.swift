import XCTest

/// Focused release smoke and genuine store screenshots using isolated demonstration data.
@MainActor
final class ReleasePreparationTests: XCTestCase {
    private var captureLanguage = "en"

    func testStoreScreenshotsAndCoreFlow() {
        captureStoreScenario(language: "en", locale: "en_US", workoutName: "Strength Session")
    }

    func testLocalizedStoreScreenshots() {
        let languages = [
            ("uk", "uk_UA", "Силове тренування"),
            ("pl", "pl_PL", "Trening siłowy"),
            ("de", "de_DE", "Krafttraining"),
            ("fr", "fr_FR", "Séance de renforcement")
        ]
        for (language, locale, workoutName) in languages {
            captureStoreScenario(language: language, locale: locale, workoutName: workoutName)
        }
    }

    private func captureStoreScenario(language: String, locale: String, workoutName: String) {
        captureLanguage = language
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launchEnvironment["ONLYBODY_NOTIFICATION_FIXTURE"] = "authorized"
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer {
            if (testRun?.failureCount ?? 0) > 0 { capture("qa-failure", app: app) }
            XCUIDevice.shared.orientation = .portrait
            app.terminate()
        }
        tap("workout.create", in: app)
        tap("picker.manual", in: app)
        let name = app.textFields["builder.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.tap()
        name.typeText("\(workoutName)\n")
        tap("builder.add", in: app)
        let pickerSearch = app.textFields.firstMatch
        XCTAssertTrue(pickerSearch.waitForExistence(timeout: 10))
        pickerSearch.tap()
        pickerSearch.typeText(JourneyProduct.exercise)
        tap("exercise.pick.\(JourneyProduct.exercise)", in: app)
        XCTAssertTrue(app.staticTexts["stepper.Sets.value"].waitForExistence(timeout: 10))
        let save = app.buttons["builder.save"]
        XCTAssertTrue(save.isHittable)
        XCTAssertGreaterThan(save.frame.width, save.frame.height, "Localized Save must remain a horizontal button")
        capture("02-workout-builder", app: app)
        tap("builder.save", in: app)
        XCTAssertTrue(app.buttons["workout.start.\(workoutName)"].waitForExistence(timeout: 10))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["workout.start.\(workoutName)"].waitForExistence(timeout: 10))
        capture("01-train", app: app)
        tap("workout.edit.\(workoutName)", in: app)
        tap("stepper.Reps.increase", in: app)
        tap("builder.save", in: app)
        tap("workout.start.\(workoutName)", in: app)
        XCTAssertTrue(app.buttons["active.markSetDone"].waitForExistence(timeout: 10))
        capture("03-active-workout", app: app)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
            waitForLandscape(in: app)
            capture("qa-active-landscape", app: app)
            XCUIDevice.shared.orientation = .portrait
        }
        for index in 0..<3 {
            tap("active.markSetDone", in: app)
            if index < 2 { tap("rest.skip", in: app) }
        }
        tap("active.close", in: app)
        tap("tab.log", in: app)
        XCTAssertTrue(app.buttons["session.row"].waitForExistence(timeout: 10))
        capture("04-training-log", app: app)
        tap("tab.library", in: app)
        XCTAssertTrue(app.textFields["library.search"].waitForExistence(timeout: 10))
        capture("05-exercise-library", app: app)
        let search = app.textFields["library.search"]
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        tap("library.exercise.\(JourneyProduct.libraryExercise)", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["movement.muscleDiagram"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.webViews.count, 0, "Fresh installs must not load YouTube before permission")
        capture("06-exercise-guide", app: app)
        let permission = app.buttons["demonstration.openYouTube"]
        for _ in 0..<5 where !permission.isHittable { app.swipeUp() }
        XCTAssertTrue(permission.isHittable)
        capture("qa-youtube-permission", app: app)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
            waitForLandscape(in: app)
            capture("qa-guide-landscape", app: app)
            XCUIDevice.shared.orientation = .portrait
        }
        tap("movement.back", in: app)
        tap("tab.train", in: app)
        tap("train.settings", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["settings.youtubeConsent"].waitForExistence(timeout: 10))
        capture("qa-settings", app: app)
    }

    private func waitForLandscape(in app: XCUIApplication) {
        let landscape = NSPredicate { _, _ in app.frame.width > app.frame.height }
        expectation(for: landscape, evaluatedWith: app)
        waitForExpectations(timeout: 10)
    }

    private func tap(_ identifier: String, in app: XCUIApplication) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing button: \(identifier)")
        button.tap()
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        let prefix = captureLanguage == "en" ? JourneyProduct.name : "\(JourneyProduct.name)-\(captureLanguage)"
        attachment.name = "\(prefix)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
