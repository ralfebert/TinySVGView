// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreText
import Foundation
import WebColor

public struct SVGText: SVGShape {

    public enum Anchor: String {
        case start, middle, end
    }

    public var text: String
    public var font: SVGFont
    public var anchor: Anchor
    /// The text origin: `x` is placed according to `anchor`, `y` is the baseline.
    public var x: CGFloat
    public var y: CGFloat

    public var fill: SVGPaint
    public var stroke: SVGStroke?

    public var id: String?
    public var transform: CGAffineTransform
    public var opacity: Double

    public init(text: String = "", font: SVGFont = SVGFont(), anchor: Anchor = .start, x: CGFloat = 0, y: CGFloat = 0, fill: SVGPaint = .unspecified, stroke: SVGStroke? = nil, id: String? = nil, transform: CGAffineTransform = .identity, opacity: Double = 1) {
        self.text = text
        self.font = font
        self.anchor = anchor
        self.x = x
        self.y = y
        self.fill = fill
        self.stroke = stroke
        self.id = id
        self.transform = transform
        self.opacity = opacity
    }

    public func makeLine() -> CTLine {
        var attributes: [NSAttributedString.Key: Any] = [
            kCTFontAttributeName as NSAttributedString.Key: font.ctFont,
        ]
        if let color = fill.paintColor {
            attributes[kCTForegroundColorAttributeName as NSAttributedString.Key] = color.cgColor
        }
        return CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
    }

    /// Offset from `x` to the start of the line, following `text-anchor`.
    public func anchorOffset(of line: CTLine) -> CGFloat {
        switch anchor {
        case .start: 0
        case .middle: -CTLineGetTypographicBounds(line, nil, nil, nil) / 2
        case .end: -CTLineGetTypographicBounds(line, nil, nil, nil)
        }
    }

    public var frame: CGRect {
        let line = makeLine()
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        return CGRect(x: x + anchorOffset(of: line), y: y - ascent, width: width, height: ascent + descent)
    }

    public var bounds: CGRect {
        self.frame
    }

}
