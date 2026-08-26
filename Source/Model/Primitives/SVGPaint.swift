// MIT license
// Derived from https://github.com/exyte/SVGView

import WebColor

public enum SVGPaint: Equatable {

    /// The document has no such attribute. TinySVGView doesn't paint it, whereas the SVG default for a
    /// missing `fill` would be black.
    case unspecified
    /// An explicit `none`.
    case none
    case color(WrittenWebColor)

}
