import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct WeightUnitTests {
    @Test func usesExactPoundDefinitionAndPreservesRoundTrips() {
        #expect(WeightUnit.pounds.kilograms(from: 1) == 0.45359237)
        #expect(abs(WeightUnit.pounds.value(fromKilograms: 20) - 44.092452437) < 0.000000001)
        for unit in WeightUnit.allCases {
            for kilograms in [0.0, 2.5, 20, 123.456789] {
                #expect(abs(unit.kilograms(from: unit.value(fromKilograms: kilograms)) - kilograms) < 0.000000001)
            }
        }
    }

    @Test(arguments: WeightUnit.allCases)
    func stepsInSelectedUnitsAndStopsAtZero(unit: WeightUnit) {
        var kilograms = 0.0
        for _ in 0..<100 { kilograms = unit.stepping(kilograms: kilograms, increasing: true) }
        #expect(abs(unit.value(fromKilograms: kilograms) - unit.step * 100) < 0.000000001)
        for _ in 0..<101 { kilograms = unit.stepping(kilograms: kilograms, increasing: false) }
        #expect(kilograms == 0)
        #expect(unit.stepping(kilograms: 0.1, increasing: false) == 0)
        #expect(WeightUnit.kilograms.step == 2.5)
        #expect(WeightUnit.pounds.step == 5)
    }

    @Test func formatsAtMostTwoFractionDigitsWithTheUsersLocale() {
        let english = Locale(identifier: "en_US")
        #expect(WeightUnit.kilograms.formatted(kilograms: 20, locale: english) == "20 kg")
        #expect(WeightUnit.kilograms.formatted(kilograms: 2.5, locale: english) == "2.5 kg")
        #expect(WeightUnit.pounds.formatted(kilograms: 20, locale: english) == "44.09 lb")
        #expect(WeightUnit.pounds.formatted(kilograms: 20, locale: Locale(identifier: "de_DE")) == "44,09 lb")
    }
}
