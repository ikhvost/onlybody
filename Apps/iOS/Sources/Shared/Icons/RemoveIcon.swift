import SwiftUI

struct RemoveIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            context.stroke(Path(roundedRect: CGRect(x: 3, y: 3, width: 18, height: 18), cornerRadius: 1), with: .color(color), style: AppIcons.stroke)

            var firstDiagonal = Path()
            firstDiagonal.move(to: CGPoint(x: 8, y: 8))
            firstDiagonal.addLine(to: CGPoint(x: 16, y: 16))
            context.stroke(firstDiagonal, with: .color(color), style: AppIcons.stroke)

            var secondDiagonal = Path()
            secondDiagonal.move(to: CGPoint(x: 16, y: 8))
            secondDiagonal.addLine(to: CGPoint(x: 8, y: 16))
            context.stroke(secondDiagonal, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
