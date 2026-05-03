import SwiftUI

struct ChevronIcon: View {
    var isBack = false
    var color: Color = Theme.text
    var size: CGFloat = 20
    var inset: CGFloat = 7

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var path = Path()
            if isBack {
                path.move(to: CGPoint(x: AppIcons.viewport - inset, y: 4))
                path.addLine(to: CGPoint(x: inset, y: 12))
                path.addLine(to: CGPoint(x: AppIcons.viewport - inset, y: 20))
            } else {
                path.move(to: CGPoint(x: inset, y: 4))
                path.addLine(to: CGPoint(x: AppIcons.viewport - inset, y: 12))
                path.addLine(to: CGPoint(x: inset, y: 20))
            }
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
