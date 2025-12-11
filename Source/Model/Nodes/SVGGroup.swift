// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public protocol SVGNodeContainer: SVGNode {
    var contents: [SVGNode] { get set }
}

public struct SVGGroup: SVGNodeContainer {

    public var transform: CGAffineTransform
    public var opacity: Double
    public var id: String?
    public var contents: [SVGNode] = []

    public init(contents: [SVGNode], transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.transform = transform
        self.opacity = opacity
        self.contents = contents
    }

    public var bounds: CGRect {
        contents.map { $0.bounds }.reduce(contents.first?.bounds ?? CGRect.zero) { $0.union($1) }
    }

    public var frame: CGRect {
        fatalError()
    }

}
