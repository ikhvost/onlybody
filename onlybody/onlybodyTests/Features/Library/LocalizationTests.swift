import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct LocalizationTests {
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

    @Test
    func unknownAndCustomNamesRemainUntouched() {
        #expect(CatalogLocalization.exercise("My own exercise", locale: Locale(identifier: "fr")) == "My own exercise")
        #expect(CatalogLocalization.label("Custom equipment", locale: Locale(identifier: "de")) == "Custom equipment")
    }

    @Test
    func catalogNamesUseCorrectLanguage() {
        #expect(CatalogLocalization.exercise("Barbell Bench Press", locale: Locale(identifier: "uk")) == "Жим штанги лежачи")
        #expect(CatalogLocalization.exercise("Standard Push-Ups", locale: Locale(identifier: "pl")) == "Pompki klasyczne")
        #expect(CatalogLocalization.exercise("Standard Push-Ups", locale: Locale(identifier: "de")) == "Klassische Liegestütze")
        #expect(CatalogLocalization.exercise("Standard Push-Ups", locale: Locale(identifier: "fr")) == "Pompes classiques")
    }

    @Test(arguments: ["en", "uk", "pl", "de", "fr"])
    func formattedResourcesResolveAllArguments(_ language: String) {
        var resource = LocalizedStringResource.uiMovementSummary(3, 12, 45)
        resource.locale = Locale(identifier: language)
        let text = String(localized: resource)
        #expect(text.contains("3"))
        #expect(text.contains("12"))
        #expect(text.contains("45"))
        #expect(!text.contains("%"))
        #expect(!text.contains("uiMovementSummary"))
    }
}
