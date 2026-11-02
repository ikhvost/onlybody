import Foundation
import Testing
@testable import onlyweights

@MainActor
struct CatalogLocalizationTests {
    @Test(arguments: ["uk", "pl", "de", "fr"])
    func catalogTranslationsPreserveCanonicalData(_ language: String) {
        let exercise = ExerciseSnapshot(name: "Barbell Bench Press", primaryMuscle: "Chest", equipment: ["Wall"])
        let locale = Locale(identifier: language)
        let translated = CatalogLocalization.exercise(exercise.name, locale: locale)
        #expect(translated != exercise.name)
        #expect(!translated.hasPrefix("exercise"))
        #expect(exercise.name == "Barbell Bench Press")
        #expect(exercise.primaryMuscle == "Chest")
        #expect(exercise.equipment == ["Wall"])
        #expect(exercise.matchesMuscleFilter("Chest"))
        #expect(CatalogLocalization.label("Mon", locale: locale) != "Mon")
        #expect(CatalogLocalization.label("Chest", locale: locale) != "Chest")
        #expect(Weekdays.shortNames.first == "Sun")
    }

    @Test(arguments: [
        ("en", "Barbell Bench Press"),
        ("uk", "Жим штанги лежачи"),
        ("pl", "Wyciskanie sztangi leżąc"),
        ("de", "Langhantel-Bankdrücken"),
        ("fr", "Développé couché à la barre")
    ])
    func exerciseUsesRequestedLanguage(language: String, expected: String) {
        #expect(CatalogLocalization.exercise("Barbell Bench Press", locale: Locale(identifier: language)) == expected)
    }
}
