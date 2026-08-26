// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGLine: SVGShape {

    public var x1: CGFloat
    public var y1: CGFloat
    public var x2: CGFloat
    public var y2: CGFloat

    /// A line has nothing to fill, the property is only here to satisfy `SVGShape`.
    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(x1: CGFloat = 0, y1: CGFloat = 0, x2: CGFloat = 0, y2: CGFloat = 0, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var frame: CGRect {
        CGRect(x: min(x1, x2), y: min(y1, y2), width: abs(x2 - x1), height: abs(y2 - y1))
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        return path
    }

}
