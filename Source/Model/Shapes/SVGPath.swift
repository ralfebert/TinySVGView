// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGPath: SVGShape {

    public var segments: [PathSegment]
    public var fillRule: CGPathFillRule

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(segments: [PathSegment] = [], fillRule: CGPathFillRule = .winding, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.segments = segments
        self.fillRule = fillRule
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var frame: CGRect {
        toBezierPath().cgPath.boundingBoxOfPath
    }

    public var bounds: CGRect {
        self.frame
    }

}
