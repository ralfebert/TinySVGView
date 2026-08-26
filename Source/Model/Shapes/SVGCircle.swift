// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGCircle: SVGShape {

    public var cx: CGFloat
    public var cy: CGFloat
    public var r: CGFloat

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(cx: CGFloat = 0, cy: CGFloat = 0, r: CGFloat = 0, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.cx = cx
        self.cy = cy
        self.r = r
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
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
