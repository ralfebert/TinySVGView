// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGPolyline: SVGShape {

    public var points: [CGPoint]
    public var fillRule: CGPathFillRule

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(points: [CGPoint] = [], fillRule: CGPathFillRule = .winding, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.points = points
        self.fillRule = fillRule
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var frame: CGRect {
        toPath().boundingBoxOfPath
    }

    public var bounds: CGRect {
        self.frame
    }

    public func toPath() -> CGPath {
        points.toPath(closed: false)
    }

}

extension [CGPoint] {

    func toPath(closed: Bool) -> CGPath {
        let path = CGMutablePath()
        path.addLines(between: self)
        if closed {
            path.closeSubpath()
        }
        return path
    }

}
