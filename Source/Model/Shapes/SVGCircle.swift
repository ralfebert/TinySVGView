// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGCircle: SVGShape {

    public var transform: CGAffineTransform = .identity
    public var opacity: Double = 1
    public var id: String?

    public var fill: SVGPaint = .unspecified
    public var stroke: SVGStroke?

    public var cx: CGFloat
    public var cy: CGFloat
    public var r: CGFloat

    public init(cx: CGFloat = 0, cy: CGFloat = 0, r: CGFloat = 0) {
        self.cx = cx
        self.cy = cy
        self.r = r
    }

    public var frame: CGRect {
        CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        CGPath(ellipseIn: frame, transform: nil)
    }

}
