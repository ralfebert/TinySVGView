// MIT license
// Derived from https://github.com/exyte/SVGView

public protocol SVGShape: SVGNode {

    var fill: SVGPaint? { get set }
    var stroke: SVGStroke? { get set }

}
