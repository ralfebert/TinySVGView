// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGPolygon: SVGShape {

    public var transform: CGAffineTransform = .identity
    public var opacity: Double = 1
    public var id: String?

    public var fill: SVGPaint = .unspecified
    public var stroke: SVGStroke?

    public var points: [CGPoint]
    public var fillRule: CGPathFillRule

    public init(points: [CGPoint] = [], fillRule: CGPathFillRule = .winding) {
        self.points = points
        self.fillRule = fillRule
    }

    public var frame: CGRect {
        toPath().boundingBoxOfPath
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        points.toPath(closed: true)
    }

}
