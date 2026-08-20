// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGEllipse: SVGShape {

    public var transform: CGAffineTransform = .identity
    public var opacity: Double = 1
    public var id: String?

    public var fill: SVGPaint = .unspecified
    public var stroke: SVGStroke?

    public var cx: CGFloat
    public var cy: CGFloat
    public var rx: CGFloat
    public var ry: CGFloat

    public init(cx: CGFloat = 0, cy: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0) {
        self.cx = cx
        self.cy = cy
        self.rx = rx
        self.ry = ry
    }

    public var frame: CGRect {
        CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2)
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        CGPath(ellipseIn: frame, transform: nil)
    }

}
