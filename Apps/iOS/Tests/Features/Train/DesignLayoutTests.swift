import Foundation
import SwiftUI
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct DesignLayoutTests {
    @Test func textPaletteMeetsContrastOnEverySurface() {
        for foreground in [Theme.text, Theme.text2, Theme.text3, Theme.accent, Theme.danger] {
            for background in [Theme.bg, Theme.surface, Theme.surface2] {
                let light = luminance(foreground)
                let dark = luminance(background)
                #expect((max(light, dark) + 0.05) / (min(light, dark) + 0.05) >= 4.5)
            }
        }
        #expect((luminance(Theme.accent) + 0.05) / (luminance(Theme.accentDark) + 0.05) >= 4.5)
    }

    private func luminance(_ color: Color) -> Double {
        let resolved = color.resolve(in: EnvironmentValues())
        func linear(_ value: Float) -> Double {
            let component = Double(value)
            return component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(resolved.red) + 0.7152 * linear(resolved.green) + 0.0722 * linear(resolved.blue)
    }
}
