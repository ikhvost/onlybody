import SwiftUI

struct EditIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var pencil = Path()
            pencil.move(to: CGPoint(x: 4, y: 20))
            pencil.addLine(to: CGPoint(x: 8, y: 19))
            pencil.addLine(to: CGPoint(x: 19, y: 8))
            pencil.addLine(to: CGPoint(x: 16, y: 5))
            pencil.addLine(to: CGPoint(x: 5, y: 17))
            pencil.closeSubpath()
            context.stroke(pencil, with: .color(color), style: AppIcons.stroke)

            var detail = Path()
            detail.move(to: CGPoint(x: 14, y: 6))
            detail.addLine(to: CGPoint(x: 17, y: 9))
            context.stroke(detail, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
