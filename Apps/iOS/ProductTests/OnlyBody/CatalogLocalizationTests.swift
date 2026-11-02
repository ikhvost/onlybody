import Foundation
import Testing
@testable import onlybody

@MainActor
struct CatalogLocalizationTests {
    @Test(arguments: ["uk", "pl", "de", "fr"])
    func catalogTranslationsPreserveCanonicalData(_ language: String) {
        let exercise = ExerciseSnapshot(name: "Standard Push-Ups", primaryMuscle: "Chest", equipment: ["Wall"])
        let locale = Locale(identifier: language)
        let translated = CatalogLocalization.exercise(exercise.name, locale: locale)
        #expect(translated != exercise.name)
        #expect(!translated.hasPrefix("exercise"))
        #expect(exercise.name == "Standard Push-Ups")
        #expect(exercise.primaryMuscle == "Chest")
        #expect(exercise.equipment == ["Wall"])
        #expect(exercise.matchesMuscleFilter("Chest"))
        #expect(CatalogLocalization.label("Mon", locale: locale) != "Mon")
        #expect(CatalogLocalization.label("Chest", locale: locale) != "Chest")
        #expect(Weekdays.shortNames.first == "Sun")
    }

    @Test(arguments: [
        ("en", "Standard Push-Ups"),
        ("uk", "Класичні віджимання"),
        ("pl", "Pompki klasyczne"),
        ("de", "Klassische Liegestütze"),
        ("fr", "Pompes classiques")
    ])
    func exerciseUsesRequestedLanguage(language: String, expected: String) {
        #expect(CatalogLocalization.exercise("Standard Push-Ups", locale: Locale(identifier: language)) == expected)
    }
}
