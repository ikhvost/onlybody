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

    static let horizontalPadding: CGFloat = 22
    static let cornerRadius: CGFloat = 4
    static let chipCornerRadius: CGFloat = 4
    static let typographyScale: CGFloat = 1.1

    static func fontSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: size * typographyScale).weight(weight)
    }

    static func fontMono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Mono", size: size * typographyScale).weight(weight)
    }

    // Fixed metrics shared by screen components.
    static let space0: CGFloat = 0
    static let space2: CGFloat = 2
    static let space3: CGFloat = 3
    static let space4: CGFloat = 4
    static let space5: CGFloat = 5
    static let space6: CGFloat = 6
    static let space7: CGFloat = 7
    static let space8: CGFloat = 8
    static let space9: CGFloat = 9
    static let space10: CGFloat = 10
    static let space11: CGFloat = 11
    static let space12: CGFloat = 12
    static let space13: CGFloat = 13
    static let space14: CGFloat = 14
    static let space15: CGFloat = 15
    static let space16: CGFloat = 16
    static let space18: CGFloat = 18
    static let space19: CGFloat = 19
    static let space20: CGFloat = 20
    static let space22: CGFloat = 22
    static let space24: CGFloat = 24
    static let space28: CGFloat = 28
    static let space44: CGFloat = 44
    static let space48: CGFloat = 48
    static let type9: CGFloat = 9
    static let type10: CGFloat = 10
    static let type11: CGFloat = 11
    static let type12: CGFloat = 12
    static let type13: CGFloat = 13
    static let type14: CGFloat = 14
    static let type15: CGFloat = 15
    static let type16: CGFloat = 16
    static let type18: CGFloat = 18
    static let type19: CGFloat = 19
    static let type20: CGFloat = 20
    static let type24: CGFloat = 24
    static let type26: CGFloat = 26
    static let type28: CGFloat = 28
    static let type38: CGFloat = 38
    static let type72: CGFloat = 72
    static let type84: CGFloat = 84
    static let type112: CGFloat = 112
}
