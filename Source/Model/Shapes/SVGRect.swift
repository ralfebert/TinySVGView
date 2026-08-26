// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGRect: SVGShape {

    public var x: CGFloat
    public var y: CGFloat
    public var width: CGFloat
    public var height: CGFloat
    public var rx: CGFloat
    public var ry: CGFloat

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rx = rx
        self.ry = ry
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var frame: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        if rx > 0 || ry > 0 {
            return CGPath(roundedRect: frame, cornerWidth: rx, cornerHeight: ry, transform: nil)
        }
        return CGPath(rect: frame, transform: nil)
    }

}
