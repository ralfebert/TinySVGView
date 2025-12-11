// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public struct SVGViewport: SVGNodeContainer {

    public var width: CGFloat
    public var height: CGFloat
    public var preserveAspectRatio: SVGPreserveAspectRatio

    public var transform: CGAffineTransform
    public var opacity: Double
    public var id: String?
    public var contents: [SVGNode] = []

    public init(width: CGFloat, height: CGFloat, preserveAspectRatio: SVGPreserveAspectRatio, contents: [SVGNode] = []) {
        self.width = width
        self.height = height
        self.preserveAspectRatio = preserveAspectRatio
        self.contents = contents
        self.transform = .identity
        self.opacity = 1
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
