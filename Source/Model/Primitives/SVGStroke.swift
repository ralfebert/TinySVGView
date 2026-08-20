// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

/// Where the stroke sits relative to the outline. Not an SVG property (`stroke-alignment` was
/// dropped from SVG 2), so it is never read from or written to a document — set it in code.
public enum StrokeAlignment {
    case center
    case inside
    case outside
}

public struct SVGStroke {

    public var fill: SVGPaint
    public var width: CGFloat
    public var cap: CGLineCap
    public var join: CGLineJoin
    public var miterLimit: CGFloat
    public var dashes: [CGFloat]
    public var offset: CGFloat
    public var alignment: StrokeAlignment

    public init(fill: SVGPaint = .color(.black), width: CGFloat = 1, cap: CGLineCap = .butt, join: CGLineJoin = .miter, miterLimit: CGFloat = 4, dashes: [CGFloat] = [], offset: CGFloat = 0.0, alignment: StrokeAlignment = .center) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.miterLimit = miterLimit
        self.dashes = dashes
        self.offset = offset
        self.alignment = alignment
    }

}
