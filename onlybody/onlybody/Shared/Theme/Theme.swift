import SwiftUI

enum Theme {
    static let typeBody: CGFloat = 18
    static let typeMeta: CGFloat = 15
    static let typeCard: CGFloat = 20
    static let typeHeading: CGFloat = 32
    static let typeExercise: CGFloat = 28
    static let typeNumber: CGFloat = 40
    static let typeTimer: CGFloat = 80
    static let touchSize: CGFloat = 44
    static let stepSize: CGFloat = 48
    static let buttonHeight: CGFloat = 56
    static let completeHeight: CGFloat = 64
    static let buttonRadius: CGFloat = 12
    static let cardInset: CGFloat = 16
    static let sectionGap: CGFloat = 24
    static let timingPickerHeight: CGFloat = 340
    static let timingWheelHeight: CGFloat = 210
    static let brandBackground = Color(white: 0.02)
    static let brandPrimary = Color(white: 0.94)
    static let brandSecondary = Color(white: 0.52)
    static let brandLetterScale: CGFloat = 0.68
    static let brandLetterOffset: CGFloat = 0.13
    static let brandIconMarkSize: CGFloat = 760
    static let brandLaunchMarkSize: CGFloat = 112

    static let activityCellHeight: CGFloat = 9
    static let activityCellCornerRadius: CGFloat = 1
    static let backSwipeStartWidth: CGFloat = 80
    static let backSwipeDuration: Double = 0.3
    static let backSwipeParallax: CGFloat = 0.25
    static let backSwipeCompletion: CGFloat = 0.4
    static let backSwipeSpeed: CGFloat = 500
    static let swipeDirectionRatio: Double = 1.5
    static let tabSwipeThresholds = TabSwipeThresholds(minimum: 16, distance: 72, fastDistance: 24, speed: 500, ratio: swipeDirectionRatio)
    static let tabTransitionDuration: Double = 0.25

    static let accent = Color(red: 232 / 255, green: 162 / 255, blue: 58 / 255)
    static let accentDim = Color(red: 232 / 255, green: 162 / 255, blue: 58 / 255, opacity: 0.13)
    static let accentDark = Color(red: 12 / 255, green: 12 / 255, blue: 11 / 255)
    static let bg = Color(red: 16 / 255, green: 17 / 255, blue: 15 / 255)
    static let surface = Color(red: 27 / 255, green: 29 / 255, blue: 25 / 255)
    static let surface2 = Color(red: 36 / 255, green: 39 / 255, blue: 32 / 255)
    static let border = Color(red: 255 / 255, green: 250 / 255, blue: 230 / 255, opacity: 0.07)
    static let border2 = Color(red: 255 / 255, green: 250 / 255, blue: 230 / 255, opacity: 0.13)
    static let text = Color(red: 245 / 255, green: 240 / 255, blue: 232 / 255)
    static let text2 = Color(red: 185 / 255, green: 182 / 255, blue: 174 / 255)
    static let text3 = Color(red: 150 / 255, green: 147 / 255, blue: 139 / 255)
    static let iconDim = Color(red: 150 / 255, green: 147 / 255, blue: 139 / 255)
    static let danger = Color(red: 255 / 255, green: 150 / 255, blue: 137 / 255)

    static let horizontalPadding: CGFloat = 20
    static let cornerRadius: CGFloat = 16
    static let chipCornerRadius: CGFloat = 12
    static let typographyScale: CGFloat = 1
    static let demonstrationMinimumWidth: CGFloat = 200
    static let demonstrationHeight: CGFloat = 240
    static let muscleDiagramMaximumWidth: CGFloat = 560
    static let muscleDiagramNeutral = Color(white: 0.66)
    static let muscleDiagramSecondary = Color(red: 143 / 255, green: 171 / 255, blue: 176 / 255).opacity(0.6)
    static let muscleLegendMarkerSize: CGFloat = 8

    static func fontSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: size).weight(weight)
    }

    static func fontMono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Mono", size: size).weight(weight)
    }

    // Fixed metrics shared by screen components.
    static let headerActionSize: CGFloat = 44
    static let dividerThickness: CGFloat = 1
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
