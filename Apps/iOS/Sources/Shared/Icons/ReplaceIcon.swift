import SwiftUI

/// Two opposing arrows for replacing an exercise.
struct ReplaceIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type24

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            var path = Path()
            path.move(to: CGPoint(x: 7, y: 19))
            path.addLine(to: CGPoint(x: 7, y: 5))
            path.move(to: CGPoint(x: 3, y: 9))
            path.addLine(to: CGPoint(x: 7, y: 5))
            path.addLine(to: CGPoint(x: 11, y: 9))
            path.move(to: CGPoint(x: 17, y: 5))
            path.addLine(to: CGPoint(x: 17, y: 19))
            path.move(to: CGPoint(x: 13, y: 15))
            path.addLine(to: CGPoint(x: 17, y: 19))
            path.addLine(to: CGPoint(x: 21, y: 15))
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
