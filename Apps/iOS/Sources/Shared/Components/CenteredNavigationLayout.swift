import SwiftUI

/// Reserves equal space beside the title, including the system button style's padding.
struct CenteredNavigationLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let leading = subviews[0].sizeThatFits(.unspecified)
        let trailing = subviews[2].sizeThatFits(.unspecified)
        let sideWidth = max(leading.width, trailing.width)
        let width = proposal.width ?? subviews[1].sizeThatFits(.unspecified).width + 2 * (sideWidth + spacing)
        let title = subviews[1].sizeThatFits(ProposedViewSize(width: max(0, width - 2 * (sideWidth + spacing)), height: nil))
        return CGSize(width: width, height: max(leading.height, trailing.height, title.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let leading = subviews[0].sizeThatFits(.unspecified)
        let trailing = subviews[2].sizeThatFits(.unspecified)
        let sideWidth = max(leading.width, trailing.width)
        subviews[0].place(at: CGPoint(x: bounds.minX, y: bounds.midY), anchor: .leading, proposal: ProposedViewSize(leading))
        subviews[1].place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center,
                          proposal: ProposedViewSize(width: max(0, bounds.width - 2 * (sideWidth + spacing)), height: nil))
        subviews[2].place(at: CGPoint(x: bounds.maxX, y: bounds.midY), anchor: .trailing, proposal: ProposedViewSize(trailing))
    }
}
