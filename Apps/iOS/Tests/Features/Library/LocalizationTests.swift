import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct LocalizationTests {
    @Test
    func unknownAndCustomNamesRemainUntouched() {
        #expect(CatalogLocalization.exercise("My own exercise", locale: Locale(identifier: "fr")) == "My own exercise")
        #expect(CatalogLocalization.label("Custom equipment", locale: Locale(identifier: "de")) == "Custom equipment")
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
