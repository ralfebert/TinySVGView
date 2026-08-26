// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

/// A `<defs>` container: its contents are only rendered when referenced via `SVGUse`.
public struct SVGDefs: SVGNodeContainer {

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
        .zero
    }

    public var frame: CGRect {
        fatalError()
    }

}

/// A `<use xlink:href="#id">` reference. It is resolved while drawing by looking up the id in the
/// document, so no separate resolve step is needed after parsing or when building a tree by hand.
public struct SVGUse: SVGNode {

    /// The referenced element's id, without the leading `#`.
    public var href: String

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(href: String = "", id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.href = href
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    /// Not known without the surrounding document, which holds the referenced node.
    public var bounds: CGRect {
        .zero
    }

    public var frame: CGRect {
        fatalError()
    }

}
