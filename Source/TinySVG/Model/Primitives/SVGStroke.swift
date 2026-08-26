// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import WebColor

public struct SVGStroke {

    public var fill: SVGPaint
    public var width: CGFloat
    public var cap: CGLineCap
    public var join: CGLineJoin
    public var miterLimit: CGFloat
    public var dashes: [CGFloat]
    public var offset: CGFloat

    public init(fill: SVGPaint = .color(.black), width: CGFloat = 1, cap: CGLineCap = .butt, join: CGLineJoin = .miter, miterLimit: CGFloat = 4, dashes: [CGFloat] = [], offset: CGFloat = 0.0) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.miterLimit = miterLimit
        self.dashes = dashes
        self.offset = offset
    }

}
