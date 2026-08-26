// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGViewport: SVGNodeContainer {

    public var width: CGFloat
    public var height: CGFloat
    public var preserveAspectRatio: SVGPreserveAspectRatio
    public var contents: [SVGNode]

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(width: CGFloat = 0, height: CGFloat = 0, preserveAspectRatio: SVGPreserveAspectRatio = SVGPreserveAspectRatio(), contents: [SVGNode] = [], id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.width = width
        self.height = height
        self.preserveAspectRatio = preserveAspectRatio
        self.contents = contents
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public var size: CGSize {
        get {
            CGSize(width: width, height: height)
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }

    public var bounds: CGRect {
        CGRect(origin: .zero, size: self.size)
    }

    public var frame: CGRect {
        fatalError()
    }

}
