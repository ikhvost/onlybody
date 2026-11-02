import SwiftUI

struct LibraryIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            context.stroke(Path(ellipseIn: CGRect(x: 3.5, y: 3.5, width: 13, height: 13)), with: .color(color), style: AppIcons.stroke)

            var diagonal = Path()
            diagonal.move(to: CGPoint(x: 15, y: 15))
            diagonal.addLine(to: CGPoint(x: 19, y: 19))
            context.stroke(diagonal, with: .color(color), style: AppIcons.stroke)

            var verticalLine = Path()
            verticalLine.move(to: CGPoint(x: 10, y: 7))
            verticalLine.addLine(to: CGPoint(x: 10, y: 13))
            context.stroke(verticalLine, with: .color(color), style: AppIcons.stroke)

            var horizontalLine = Path()
            horizontalLine.move(to: CGPoint(x: 7, y: 10))
            horizontalLine.addLine(to: CGPoint(x: 13, y: 10))
            context.stroke(horizontalLine, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
