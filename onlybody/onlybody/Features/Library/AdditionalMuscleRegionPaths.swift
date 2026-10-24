import SwiftUI

/// Surface projections on the retained mannequin. Hip flexors include deep muscles;
/// their anterior hip projection is a location cue, not a depiction of exposed anatomy.
enum AdditionalMuscleRegionPaths {
    static func path(for group: MuscleGroup) -> Path {
        switch group {
        case .biceps:
            mirrored([(216, 336), (181, 354), (165, 404), (160, 438), (181, 453), (201, 426), (216, 378)], axis: 342)
        case .triceps:
            mirrored([(780, 324), (738, 347), (724, 392), (722, 425), (741, 449), (765, 411), (782, 365)], axis: 910)
        case .forearms:
            forearms()
        case .serratus:
            mirrored([(240, 353), (257, 365), (283, 376), (279, 412), (252, 429), (245, 394)], axis: 342)
        case .hipFlexors:
            mirrored([(252, 529), (284, 550), (312, 584), (303, 624), (282, 596), (264, 557)], axis: 342)
        case .adductors:
            mirrored([(313, 606), (333, 619), (330, 679), (318, 739), (306, 704), (291, 649)], axis: 342)
        default:
            Path()
        }
    }

    private static func forearms() -> Path {
        var result = mirrored(
            [(157, 457), (192, 465), (188, 497), (156, 545), (115, 598), (91, 588), (112, 531), (132, 486)],
            axis: 342)
        result.addPath(mirrored(
            [(717, 451), (746, 462), (731, 508), (710, 557), (689, 596), (664, 587), (681, 501)],
            axis: 910))
        return result
    }

    private static func mirrored(_ points: [(CGFloat, CGFloat)], axis: CGFloat) -> Path {
        let outline = Path { path in
            guard let first = points.first else { return }
            path.move(to: CGPoint(x: first.0, y: first.1))
            for point in points.dropFirst() {
                path.addLine(to: CGPoint(x: point.0, y: point.1))
            }
            path.closeSubpath()
        }
        var result = outline
        result.addPath(outline, transform: CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: axis * 2, ty: 0))
        return result
    }
}
