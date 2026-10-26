import Foundation

/// User-facing mass units. Persisted workout weights always remain in kilograms.
nonisolated enum WeightUnit: String, CaseIterable, Sendable {
    case kilograms = "kg"
    case pounds = "lb"

    var title: String {
        switch self {
        case .kilograms: String(localized: .uiKilogramsKg)
        case .pounds: String(localized: .uiPoundsLb)
        }
    }

    var step: Double { self == .kilograms ? 2.5 : 5 }

    private var kilogramsPerUnit: Double { self == .kilograms ? 1 : 0.45359237 }

    func value(fromKilograms kilograms: Double) -> Double { kilograms / kilogramsPerUnit }

    func kilograms(from value: Double) -> Double { value * kilogramsPerUnit }

    /// Rounds only arithmetic noise during editing, never stored history or a unit change.
    func stepping(kilograms: Double, increasing: Bool) -> Double {
        let next = max(0, value(fromKilograms: kilograms) + (increasing ? step : -step))
        let normalized = (next * 1_000_000_000).rounded() / 1_000_000_000
        return self.kilograms(from: normalized)
    }

    func formatted(kilograms: Double, locale: Locale = .current) -> String {
        let number = value(fromKilograms: kilograms).formatted(
            .number.precision(.fractionLength(0...2)).grouping(.never).locale(locale)
        )
        return "\(number) \(rawValue)"
    }
}
