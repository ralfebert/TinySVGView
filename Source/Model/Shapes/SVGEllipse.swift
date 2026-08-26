// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGEllipse: SVGShape {

    public var cx: CGFloat
    public var cy: CGFloat
    public var rx: CGFloat
    public var ry: CGFloat

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(cx: CGFloat = 0, cy: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.cx = cx
        self.cy = cy
        self.rx = rx
        self.ry = ry
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
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
