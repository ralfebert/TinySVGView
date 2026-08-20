// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGRect: SVGShape {

    public var transform: CGAffineTransform = .identity
    public var opacity: Double = 1
    public var id: String?

    public var fill: SVGPaint = .unspecified
    public var stroke: SVGStroke?

    public var x: CGFloat
    public var y: CGFloat
    public var width: CGFloat
    public var height: CGFloat
    public var rx: CGFloat
    public var ry: CGFloat

    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0, rx: CGFloat = 0, ry: CGFloat = 0) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rx = rx
        self.ry = ry
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
