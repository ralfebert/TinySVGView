// MIT license
// Derived from https://github.com/exyte/SVGView

import WebColor

public enum SVGPaint: Equatable {

    /// The document has no such attribute.
    case unspecified
    /// An explicit `fill="none"` or `stroke="none"`.
    case noPaint
    case color(WrittenWebColor)

}

public extension SVGPaint {

    static func color(_ color: WebColor) -> SVGPaint {
        .color(WrittenWebColor(color))
    }

    /// The color to paint with, `nil` for an explicit `noPaint`. A missing attribute paints black,
    /// the SVG default.
    var paintColor: WebColor? {
        switch self {
        case .unspecified: .black
        case .noPaint: nil
        case let .color(color): color.color
        }
    }

}
