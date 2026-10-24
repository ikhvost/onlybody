import SwiftUI

struct LogIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            context.stroke(Path(roundedRect: CGRect(x: 3, y: 5, width: 18, height: 16), cornerRadius: 1), with: .color(color), style: AppIcons.stroke)

            var divider = Path()
            divider.move(to: CGPoint(x: 3, y: 10))
            divider.addLine(to: CGPoint(x: 21, y: 10))
            context.stroke(divider, with: .color(color), style: AppIcons.stroke)

            var leftTab = Path()
            leftTab.move(to: CGPoint(x: 8, y: 3))
            leftTab.addLine(to: CGPoint(x: 8, y: 7))
            context.stroke(leftTab, with: .color(color), style: AppIcons.stroke)

            var rightTab = Path()
            rightTab.move(to: CGPoint(x: 16, y: 3))
            rightTab.addLine(to: CGPoint(x: 16, y: 7))
            context.stroke(rightTab, with: .color(color), style: AppIcons.stroke)

            var line1 = Path()
            line1.move(to: CGPoint(x: 7, y: 14))
            line1.addLine(to: CGPoint(x: 11, y: 14))
            context.stroke(line1, with: .color(color), style: AppIcons.stroke)

            var line2 = Path()
            line2.move(to: CGPoint(x: 13, y: 14))
            line2.addLine(to: CGPoint(x: 17, y: 14))
            context.stroke(line2, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
