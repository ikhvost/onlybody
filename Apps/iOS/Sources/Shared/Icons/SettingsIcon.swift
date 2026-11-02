import SwiftUI

struct SettingsIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var path = Path()
            for tooth in 0..<8 {
                for (offset, radius) in [(0.0, 8.0), (0.2, 10.5), (0.8, 10.5), (1.0, 8.0)] {
                    let angle = (Double(tooth) + offset) * .pi / 4 - .pi / 2
                    let point = CGPoint(x: 12 + cos(angle) * radius, y: 12 + sin(angle) * radius)
                    if tooth == 0 && offset == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            path.closeSubpath()
            path.addEllipse(in: CGRect(x: 8.5, y: 8.5, width: 7, height: 7))
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
