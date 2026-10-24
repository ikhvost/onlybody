import SwiftUI

/// Hand-aligned region boundaries for the retained 1254 × 1254 MuscleAnatomy image.
/// Replacing the reference image requires realigning these paths, not just changing the PNG.
enum MuscleRegionPaths {
    static let viewport: CGFloat = 1254

    static func path(for group: MuscleGroup) -> Path {
        switch group {
        case .chest: chest()
        case .back: back()
        case .shoulders: shoulders()
        case .arms: arms()
        case .core: core()
        case .quads: quads()
        case .glutes: glutes()
        case .hamstrings: hamstrings()
        case .calves: calves()
        }
    }

    private static func paired(_ path: Path, around axis: CGFloat) -> Path {
        var result = path
        result.addPath(path, transform: CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: axis * 2, ty: 0))
        return result
    }

    private static func chest() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 332, y: 256))
            path.addCurve(to: CGPoint(x: 270, y: 254), control1: CGPoint(x: 312, y: 246), control2: CGPoint(x: 294, y: 250))
            path.addCurve(to: CGPoint(x: 229, y: 305), control1: CGPoint(x: 251, y: 268), control2: CGPoint(x: 239, y: 291))
            path.addCurve(to: CGPoint(x: 259, y: 358), control1: CGPoint(x: 232, y: 332), control2: CGPoint(x: 241, y: 353))
            path.addCurve(to: CGPoint(x: 330, y: 348), control1: CGPoint(x: 281, y: 372), control2: CGPoint(x: 318, y: 359))
            path.addCurve(to: CGPoint(x: 332, y: 256), control1: CGPoint(x: 343, y: 329), control2: CGPoint(x: 337, y: 281))
            path.closeSubpath()
        }
        return paired(left, around: 342)
    }

    private static func back() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 906, y: 169))
            path.addCurve(to: CGPoint(x: 805, y: 239), control1: CGPoint(x: 891, y: 213), control2: CGPoint(x: 853, y: 229))
            path.addCurve(to: CGPoint(x: 839, y: 266), control1: CGPoint(x: 821, y: 244), control2: CGPoint(x: 834, y: 254))
            path.addCurve(to: CGPoint(x: 787, y: 318), control1: CGPoint(x: 819, y: 281), control2: CGPoint(x: 802, y: 303))
            path.addCurve(to: CGPoint(x: 795, y: 376), control1: CGPoint(x: 787, y: 337), control2: CGPoint(x: 791, y: 355))
            path.addCurve(to: CGPoint(x: 827, y: 469), control1: CGPoint(x: 801, y: 412), control2: CGPoint(x: 821, y: 439))
            path.addCurve(to: CGPoint(x: 817, y: 511), control1: CGPoint(x: 829, y: 483), control2: CGPoint(x: 823, y: 498))
            path.addCurve(to: CGPoint(x: 903, y: 552), control1: CGPoint(x: 850, y: 508), control2: CGPoint(x: 886, y: 534))
            path.addCurve(to: CGPoint(x: 903, y: 420), control1: CGPoint(x: 896, y: 515), control2: CGPoint(x: 889, y: 461))
            path.addLine(to: CGPoint(x: 906, y: 169))
            path.closeSubpath()
        }
        return paired(left, around: 910)
    }

    private static func shoulders() -> Path {
        let front = Path { path in
            path.move(to: CGPoint(x: 263, y: 247))
            path.addCurve(to: CGPoint(x: 198, y: 253), control1: CGPoint(x: 242, y: 237), control2: CGPoint(x: 216, y: 240))
            path.addCurve(to: CGPoint(x: 174, y: 340), control1: CGPoint(x: 174, y: 273), control2: CGPoint(x: 165, y: 310))
            path.addCurve(to: CGPoint(x: 226, y: 313), control1: CGPoint(x: 185, y: 330), control2: CGPoint(x: 209, y: 320))
            path.addCurve(to: CGPoint(x: 263, y: 247), control1: CGPoint(x: 239, y: 282), control2: CGPoint(x: 254, y: 262))
            path.closeSubpath()
        }
        let rear = Path { path in
            path.move(to: CGPoint(x: 821, y: 249))
            path.addCurve(to: CGPoint(x: 755, y: 266), control1: CGPoint(x: 797, y: 239), control2: CGPoint(x: 772, y: 247))
            path.addCurve(to: CGPoint(x: 736, y: 331), control1: CGPoint(x: 739, y: 284), control2: CGPoint(x: 731, y: 309))
            path.addCurve(to: CGPoint(x: 788, y: 307), control1: CGPoint(x: 754, y: 321), control2: CGPoint(x: 774, y: 312))
            path.addCurve(to: CGPoint(x: 821, y: 249), control1: CGPoint(x: 803, y: 282), control2: CGPoint(x: 813, y: 263))
            path.closeSubpath()
        }
        var result = paired(front, around: 342)
        result.addPath(paired(rear, around: 910))
        return result
    }

    private static func arms() -> Path {
        let front = Path { path in
            path.move(to: CGPoint(x: 220, y: 328))
            path.addCurve(to: CGPoint(x: 175, y: 354), control1: CGPoint(x: 204, y: 335), control2: CGPoint(x: 184, y: 344))
            path.addCurve(to: CGPoint(x: 154, y: 425), control1: CGPoint(x: 163, y: 374), control2: CGPoint(x: 160, y: 406))
            path.addCurve(to: CGPoint(x: 108, y: 535), control1: CGPoint(x: 135, y: 455), control2: CGPoint(x: 115, y: 497))
            path.addLine(to: CGPoint(x: 88, y: 590))
            path.addLine(to: CGPoint(x: 116, y: 600))
            path.addCurve(to: CGPoint(x: 197, y: 486), control1: CGPoint(x: 140, y: 560), control2: CGPoint(x: 183, y: 523))
            path.addCurve(to: CGPoint(x: 204, y: 446), control1: CGPoint(x: 203, y: 470), control2: CGPoint(x: 197, y: 457))
            path.addCurve(to: CGPoint(x: 220, y: 328), control1: CGPoint(x: 221, y: 408), control2: CGPoint(x: 227, y: 367))
            path.closeSubpath()
        }
        let rear = Path { path in
            path.move(to: CGPoint(x: 784, y: 322))
            path.addCurve(to: CGPoint(x: 735, y: 348), control1: CGPoint(x: 762, y: 330), control2: CGPoint(x: 744, y: 339))
            path.addCurve(to: CGPoint(x: 719, y: 422), control1: CGPoint(x: 721, y: 373), control2: CGPoint(x: 723, y: 400))
            path.addCurve(to: CGPoint(x: 681, y: 495), control1: CGPoint(x: 705, y: 445), control2: CGPoint(x: 690, y: 463))
            path.addLine(to: CGPoint(x: 661, y: 590))
            path.addLine(to: CGPoint(x: 690, y: 600))
            path.addCurve(to: CGPoint(x: 738, y: 502), control1: CGPoint(x: 709, y: 560), control2: CGPoint(x: 726, y: 536))
            path.addCurve(to: CGPoint(x: 754, y: 450), control1: CGPoint(x: 743, y: 485), control2: CGPoint(x: 741, y: 464))
            path.addCurve(to: CGPoint(x: 784, y: 322), control1: CGPoint(x: 781, y: 407), control2: CGPoint(x: 797, y: 364))
            path.closeSubpath()
        }
        var result = paired(front, around: 342)
        result.addPath(paired(rear, around: 910))
        return result
    }

    private static func core() -> Path {
        let abdomen = Path { path in
            path.move(to: CGPoint(x: 336, y: 364))
            path.addCurve(to: CGPoint(x: 296, y: 379), control1: CGPoint(x: 322, y: 358), control2: CGPoint(x: 304, y: 366))
            path.addCurve(to: CGPoint(x: 298, y: 502), control1: CGPoint(x: 291, y: 422), control2: CGPoint(x: 293, y: 462))
            path.addCurve(to: CGPoint(x: 314, y: 586), control1: CGPoint(x: 303, y: 536), control2: CGPoint(x: 305, y: 564))
            path.addLine(to: CGPoint(x: 338, y: 589))
            path.addLine(to: CGPoint(x: 338, y: 508))
            path.addQuadCurve(to: CGPoint(x: 337, y: 491), control: CGPoint(x: 329, y: 499))
            path.addLine(to: CGPoint(x: 336, y: 364))
            path.closeSubpath()
        }
        let side = Path { path in
            path.move(to: CGPoint(x: 239, y: 361))
            path.addCurve(to: CGPoint(x: 286, y: 385), control1: CGPoint(x: 249, y: 375), control2: CGPoint(x: 272, y: 378))
            path.addLine(to: CGPoint(x: 288, y: 497))
            path.addCurve(to: CGPoint(x: 294, y: 560), control1: CGPoint(x: 289, y: 519), control2: CGPoint(x: 290, y: 540))
            path.addLine(to: CGPoint(x: 249, y: 529))
            path.addCurve(to: CGPoint(x: 247, y: 463), control1: CGPoint(x: 242, y: 511), control2: CGPoint(x: 246, y: 479))
            path.addCurve(to: CGPoint(x: 239, y: 361), control1: CGPoint(x: 255, y: 431), control2: CGPoint(x: 240, y: 389))
            path.closeSubpath()
        }
        var result = paired(abdomen, around: 342)
        result.addPath(paired(side, around: 342))
        return result
    }

    private static func quads() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 245, y: 545))
            path.addCurve(to: CGPoint(x: 212, y: 668), control1: CGPoint(x: 230, y: 579), control2: CGPoint(x: 211, y: 624))
            path.addCurve(to: CGPoint(x: 224, y: 774), control1: CGPoint(x: 206, y: 713), control2: CGPoint(x: 210, y: 746))
            path.addCurve(to: CGPoint(x: 250, y: 798), control1: CGPoint(x: 232, y: 794), control2: CGPoint(x: 240, y: 800))
            path.addLine(to: CGPoint(x: 260, y: 781))
            path.addCurve(to: CGPoint(x: 288, y: 818), control1: CGPoint(x: 264, y: 802), control2: CGPoint(x: 277, y: 823))
            path.addCurve(to: CGPoint(x: 312, y: 774), control1: CGPoint(x: 301, y: 809), control2: CGPoint(x: 307, y: 792))
            path.addCurve(to: CGPoint(x: 300, y: 688), control1: CGPoint(x: 317, y: 742), control2: CGPoint(x: 306, y: 716))
            path.addCurve(to: CGPoint(x: 267, y: 574), control1: CGPoint(x: 291, y: 645), control2: CGPoint(x: 281, y: 602))
            path.addLine(to: CGPoint(x: 245, y: 545))
            path.closeSubpath()
        }
        return paired(left, around: 342)
    }

    private static func glutes() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 850, y: 524))
            path.addCurve(to: CGPoint(x: 811, y: 550), control1: CGPoint(x: 833, y: 521), control2: CGPoint(x: 820, y: 531))
            path.addCurve(to: CGPoint(x: 791, y: 653), control1: CGPoint(x: 797, y: 579), control2: CGPoint(x: 793, y: 622))
            path.addCurve(to: CGPoint(x: 854, y: 663), control1: CGPoint(x: 812, y: 670), control2: CGPoint(x: 836, y: 668))
            path.addCurve(to: CGPoint(x: 904, y: 635), control1: CGPoint(x: 883, y: 660), control2: CGPoint(x: 901, y: 651))
            path.addCurve(to: CGPoint(x: 891, y: 570), control1: CGPoint(x: 907, y: 611), control2: CGPoint(x: 901, y: 587))
            path.addCurve(to: CGPoint(x: 850, y: 524), control1: CGPoint(x: 880, y: 547), control2: CGPoint(x: 867, y: 529))
            path.closeSubpath()
        }
        return paired(left, around: 910)
    }

    private static func hamstrings() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 801, y: 674))
            path.addCurve(to: CGPoint(x: 894, y: 657), control1: CGPoint(x: 837, y: 677), control2: CGPoint(x: 873, y: 666))
            path.addCurve(to: CGPoint(x: 881, y: 773), control1: CGPoint(x: 896, y: 692), control2: CGPoint(x: 887, y: 735))
            path.addCurve(to: CGPoint(x: 849, y: 851), control1: CGPoint(x: 875, y: 804), control2: CGPoint(x: 858, y: 836))
            path.addLine(to: CGPoint(x: 833, y: 814))
            path.addLine(to: CGPoint(x: 804, y: 846))
            path.addCurve(to: CGPoint(x: 785, y: 775), control1: CGPoint(x: 793, y: 824), control2: CGPoint(x: 786, y: 800))
            path.addCurve(to: CGPoint(x: 801, y: 674), control1: CGPoint(x: 779, y: 741), control2: CGPoint(x: 785, y: 702))
            path.closeSubpath()
        }
        return paired(left, around: 910)
    }

    private static func calves() -> Path {
        let left = Path { path in
            path.move(to: CGPoint(x: 809, y: 855))
            path.addCurve(to: CGPoint(x: 773, y: 905), control1: CGPoint(x: 796, y: 864), control2: CGPoint(x: 781, y: 885))
            path.addCurve(to: CGPoint(x: 783, y: 973), control1: CGPoint(x: 763, y: 926), control2: CGPoint(x: 766, y: 956))
            path.addCurve(to: CGPoint(x: 810, y: 987), control1: CGPoint(x: 795, y: 992), control2: CGPoint(x: 801, y: 997))
            path.addLine(to: CGPoint(x: 820, y: 964))
            path.addCurve(to: CGPoint(x: 839, y: 984), control1: CGPoint(x: 825, y: 979), control2: CGPoint(x: 832, y: 988))
            path.addCurve(to: CGPoint(x: 866, y: 929), control1: CGPoint(x: 856, y: 970), control2: CGPoint(x: 867, y: 948))
            path.addCurve(to: CGPoint(x: 848, y: 868), control1: CGPoint(x: 868, y: 907), control2: CGPoint(x: 859, y: 880))
            path.addLine(to: CGPoint(x: 832, y: 887))
            path.addLine(to: CGPoint(x: 809, y: 855))
            path.closeSubpath()
        }
        return paired(left, around: 910)
    }
}
