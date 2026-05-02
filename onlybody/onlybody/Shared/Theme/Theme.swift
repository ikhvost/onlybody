import SwiftUI

enum Theme {
    static let accent = Color(red: 232 / 255, green: 162 / 255, blue: 58 / 255)
    static let accentDim = Color(red: 232 / 255, green: 162 / 255, blue: 58 / 255, opacity: 0.13)
    static let accentDark = Color(red: 12 / 255, green: 12 / 255, blue: 11 / 255)
    static let bg = Color(red: 12 / 255, green: 12 / 255, blue: 11 / 255)
    static let surface = Color(red: 22 / 255, green: 22 / 255, blue: 20 / 255)
    static let surface2 = Color(red: 30 / 255, green: 30 / 255, blue: 27 / 255)
    static let border = Color(red: 255 / 255, green: 250 / 255, blue: 230 / 255, opacity: 0.07)
    static let border2 = Color(red: 255 / 255, green: 250 / 255, blue: 230 / 255, opacity: 0.13)
    static let text = Color(red: 245 / 255, green: 240 / 255, blue: 232 / 255)
    static let text2 = Color(red: 245 / 255, green: 240 / 255, blue: 232 / 255, opacity: 0.50)
    static let text3 = Color(red: 245 / 255, green: 240 / 255, blue: 232 / 255, opacity: 0.24)
    static let iconDim = Color(red: 245 / 255, green: 240 / 255, blue: 232 / 255, opacity: 0.28)
    static let danger = Color(red: 224 / 255, green: 90 / 255, blue: 78 / 255)
    static let success = Color(red: 76 / 255, green: 175 / 255, blue: 110 / 255)

    static let horizontalPadding: CGFloat = 18
    static let cornerRadius: CGFloat = 4
    static let chipCornerRadius: CGFloat = 3
    static let space3: CGFloat = 3
    static let space6: CGFloat = 6
    static let space8: CGFloat = 8
    static let space10: CGFloat = 10
    static let space16: CGFloat = 16
    static let space24: CGFloat = 24

    static let chipToggleFontSize: CGFloat = 12
    static let chipToggleVerticalPadding: CGFloat = 9
    static let chipToggleHorizontalPadding: CGFloat = 4

    static func fontSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: size).weight(weight)
    }

    static func fontMono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Mono", size: size).weight(weight)
    }
}
