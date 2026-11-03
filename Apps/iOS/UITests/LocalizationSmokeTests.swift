import XCTest

/// Focused language selection, translated search and settings UI checks in isolated app stores.
@MainActor
final class LocalizationSmokeTests: XCTestCase {
    func testSupportedLanguages() {
        continueAfterFailure = false
        let translations = [
            ("en", "en_US", "Hollow Body Hold", "Dumbbell Reverse Fly"),
            ("uk", "uk_UA", "Утримання «човника» на спині", "Розведення гантелей у нахилі"),
            ("pl", "pl_PL", "Utrzymanie pozycji hollow body", "Odwrotne rozpiętki z hantlami"),
            ("de", "de_DE", "Hollow Body Hold", "Reverse Flys mit Kurzhanteln"),
            ("fr", "fr_FR", "Gainage hollow body", "Oiseau avec haltères")
        ]
        for (language, locale, bodyName, weightsName) in translations {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
            app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
            app.launchEnvironment["ONLYBODY_DEMONSTRATION_FIXTURE"] = "ready"
            app.launchEnvironment["ONLYBODY_NOTIFICATION_FIXTURE"] = "authorized"
            app.launch()
            defer {
                if (testRun?.failureCount ?? 0) > 0 { capture("\(language)-failure") }
                app.terminate()
            }
            tap("tab.library", in: app)
            let search = app.textFields["library.search"]
            XCTAssertTrue(search.waitForExistence(timeout: 10))
            #if ONLYWEIGHTS
            let name = weightsName
            let canonicalName = "Dumbbell Reverse Fly"
            #else
            let name = bodyName
            let canonicalName = "Hollow Body Hold"
            #endif
            search.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
            search.typeText(canonicalName)
            let row = app.buttons["library.exercise.\(canonicalName)"]
            XCTAssertTrue(row.waitForExistence(timeout: 10), "Canonical search failed: \(language)")
            search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: canonicalName.count))
            search.typeText(name)
            XCTAssertEqual(search.value as? String, name, "The keyboard must enter the full localized query")
            search.typeText("\n")
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                                                        object: app.keyboards.firstMatch)], timeout: 5), .completed)
            for _ in 0..<5 where !row.exists || !row.isHittable { app.swipeUp() }
            XCTAssertTrue(row.waitForExistence(timeout: 10), "Translated search failed: \(language), input: \(search.value ?? "nil")\n\(app.debugDescription)")
            row.tap()
            XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10))
            XCTAssertEqual(app.webViews.count, 0)
            tap("movement.back", in: app)
            tap("tab.train", in: app)
            tap("train.settings", in: app)
            XCTAssertFalse(app.descendants(matching: .any)["settings.youtubeConsent"].exists)
        }
    }

    private func tap(_ identifier: String, in app: XCUIApplication) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.exists || button.waitForExistence(timeout: 10))
        button.tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "\(JourneyProduct.name)-localization-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
