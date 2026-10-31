import XCTest

/// Captures actual screens with fictional history in a fresh, isolated store per language.
@MainActor
final class StoreScreenshotTests: XCTestCase {
    func testPopulatedScreenshots() {
        continueAfterFailure = false
        let languages = [
            ("en", "en_US", "Upper Body"),
            ("uk", "uk_UA", "Верх тіла"),
            ("pl", "pl_PL", "Góra ciała"),
            ("de", "de_DE", "Oberkörper"),
            ("fr", "fr_FR", "Haut du corps")
        ]
        for (language, locale, workout) in languages {
            captureScenario(language: language, locale: locale, workout: workout)
        }
    }

    private func captureScenario(language: String, locale: String, workout: String) {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launchEnvironment["ONLYBODY_NOTIFICATION_FIXTURE"] = "authorized"
        app.launchEnvironment["ONLYBODY_SCREENSHOT_FIXTURE"] = "populated"
        app.launchEnvironment["ONLYBODY_SCREENSHOT_LANGUAGE"] = language
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        defer { app.terminate() }
        XCTAssertTrue(app.buttons["workout.start.\(workout)"].waitForExistence(timeout: 10))
        capture("01-train", language: language)
        tap("workout.edit.\(workout)", in: app)
        let save = app.buttons["builder.save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        XCTAssertGreaterThan(save.frame.width, save.frame.height, "Save must retain its intrinsic horizontal size")
        capture("02-workout-builder", language: language)
        tap("builder.back", in: app)
        tap("workout.start.\(workout)", in: app)
        tap("active.markSetDone", in: app)
        tap("rest.skip", in: app)
        capture("03-active-workout", language: language)
        tap("active.end", in: app)
        let discardTitles = [
            "en": "End Without Saving", "uk": "Завершити без збереження", "pl": "Zakończ bez zapisywania",
            "de": "Ohne Speichern beenden", "fr": "Terminer sans enregistrer"
        ]
        let discard = app.alerts.buttons[discardTitles[language] ?? "End Without Saving"]
        XCTAssertTrue(discard.waitForExistence(timeout: 10))
        discard.tap()
        XCTAssertTrue(app.buttons["workout.start.\(workout)"].waitForExistence(timeout: 10))
        tap("tab.log", in: app)
        XCTAssertTrue(app.buttons["session.row"].firstMatch.waitForExistence(timeout: 10))
        capture("04-training-log", language: language)
        tap("tab.library", in: app)
        let search = app.textFields["library.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        capture("05-exercise-library", language: language)
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        tap("library.exercise.\(JourneyProduct.libraryExercise)", in: app)
        let permission = app.buttons["demonstration.openYouTube"]
        XCTAssertTrue(permission.waitForExistence(timeout: 10))
        capture("qa-youtube-permission", language: language)
        XCTAssertEqual(app.webViews.count, 0, "Screenshots must not enable third-party connections")
        let diagram = app.descendants(matching: .any)["movement.muscleDiagram"]
        XCTAssertTrue(diagram.waitForExistence(timeout: 10))
        app.swipeUp()
        app.swipeUp()
        capture("06-exercise-guide", language: language)
        tap("movement.back", in: app)
        tap("tab.train", in: app)
    }

    private func tap(_ identifier: String, in app: XCUIApplication) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing button: \(identifier)")
        button.tap()
    }

    private func capture(_ name: String, language: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        let prefix = language == "en" ? JourneyProduct.name : "\(JourneyProduct.name)-\(language)"
        attachment.name = "\(prefix)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
