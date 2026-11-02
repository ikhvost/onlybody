import SwiftUI

struct OrderArrowIcon: View {
    var pointsUp = true
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / AppIcons.viewport, y: size.width / AppIcons.viewport)
            var path = Path()
            let tip: CGFloat = pointsUp ? 5 : 19
            let base: CGFloat = pointsUp ? 19 : 5
            let side: CGFloat = pointsUp ? 11 : 13
            path.move(to: CGPoint(x: 12, y: base))
            path.addLine(to: CGPoint(x: 12, y: tip))
            path.move(to: CGPoint(x: 6, y: side))
            path.addLine(to: CGPoint(x: 12, y: tip))
            path.addLine(to: CGPoint(x: 18, y: side))
            context.stroke(path, with: .color(Theme.text2), style: AppIcons.stroke)
        }.frame(width: Theme.type20, height: Theme.type20)
    }
}
