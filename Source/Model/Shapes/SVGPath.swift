// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGPath: SVGShape {

    public var transform: CGAffineTransform = .identity
    public var opacity: Double = 1
    public var id: String?

    public var fill: SVGPaint?
    public var stroke: SVGStroke?

    public var segments: [PathSegment]
    public var fillRule: CGPathFillRule

    public init(segments: [PathSegment] = [], fillRule: CGPathFillRule = .winding) {
        self.segments = segments
        self.fillRule = fillRule
    }

    public var frame: CGRect {
        toBezierPath().cgPath.boundingBoxOfPath
    }

    public var bounds: CGRect {
        self.frame
    }

}
