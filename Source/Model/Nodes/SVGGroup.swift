// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public protocol SVGNodeContainer: SVGNode {
    var contents: [SVGNode] { get set }
}

public struct SVGGroup: SVGNodeContainer {

    public var contents: [SVGNode]

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(contents: [SVGNode] = [], id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.contents = contents
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var bounds: CGRect {
        contents.map { $0.bounds }.reduce(contents.first?.bounds ?? CGRect.zero) { $0.union($1) }
    }

    public var frame: CGRect {
        fatalError()
    }

}
