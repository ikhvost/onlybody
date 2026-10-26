import XCTest

/// Focused language selection, translated search and consent UI checks in isolated app stores.
@MainActor
final class LocalizationSmokeTests: XCTestCase {
    func testSupportedLanguages() {
        continueAfterFailure = false
        let translations = [
            ("en", "en_US", "Standard Push-Ups", "Barbell Bench Press"),
            ("uk", "uk_UA", "Класичні віджимання", "Жим штанги лежачи"),
            ("pl", "pl_PL", "Pompki klasyczne", "Wyciskanie sztangi leżąc"),
            ("de", "de_DE", "Klassische Liegestütze", "Langhantel-Bankdrücken"),
            ("fr", "fr_FR", "Pompes classiques", "Développé couché à la barre")
        ]
        for (language, locale, bodyName, weightsName) in translations {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
            app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
            app.launchEnvironment["ONLYBODY_NOTIFICATION_FIXTURE"] = "authorized"
            app.launch()
            defer { app.terminate() }
            tap("tab.library", in: app)
            let search = app.textFields["library.search"]
            XCTAssertTrue(search.waitForExistence(timeout: 10))
            #if ONLYWEIGHTS
            let name = weightsName
            #else
            let name = bodyName
            #endif
            search.tap()
            search.typeText(name)
            let row = app.buttons["library.exercise.\(JourneyProduct.exercise)"]
            XCTAssertTrue(row.waitForExistence(timeout: 10), "Translated search failed: \(language)")
            capture("\(language)-library")
            row.tap()
            XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10))
            XCTAssertEqual(app.webViews.count, 0)
            capture("\(language)-exercise")
            tap("movement.back", in: app)
            tap("tab.train", in: app)
            tap("train.settings", in: app)
            XCTAssertTrue(app.descendants(matching: .any)["settings.youtubeConsent"].waitForExistence(timeout: 10))
            capture("\(language)-settings")
        }
    }

    private func tap(_ identifier: String, in app: XCUIApplication) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "\(JourneyProduct.name)-localization-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
