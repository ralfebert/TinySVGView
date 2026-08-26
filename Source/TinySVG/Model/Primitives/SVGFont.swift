// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreText
import Foundation

public struct SVGFont: Hashable {

    public var family: String
    public var size: SVGLength
    public var weight: SVGFontWeight
    public var style: SVGFontStyle

    public init(family: String = "Serif", size: SVGLength = 16, weight: SVGFontWeight = .normal, style: SVGFontStyle = .normal) {
        self.family = family
        self.size = size
        self.weight = weight
        self.style = style
    }

    public var ctFont: CTFont {
        var font = CTFontCreateWithName(family as CFString, size.value, nil)
        var traits: CTFontSymbolicTraits = []
        if weight.isBold { traits.insert(.traitBold) }
        if style.isItalic { traits.insert(.traitItalic) }
        if !traits.isEmpty,
           let styled = CTFontCreateCopyWithSymbolicTraits(font, size.value, nil, traits, traits)
        {
            font = styled
        }
        return font
    }

}

/// `font-weight`: the CSS keywords and the numeric 100–900 scale.
public enum SVGFontWeight: Hashable {

    case normal
    case bold
    case bolder
    case lighter
    case number(Int)

    /// TinySVGView draws with the bold face or the regular one; there is nothing in between.
    public var isBold: Bool {
        switch self {
        case .normal, .lighter: false
        case .bold, .bolder: true
        case let .number(number): number >= 600
        }
    }

    public init?(parsing string: String) {
        switch string.trimmingCharacters(in: .whitespaces).lowercased() {
        case "normal": self = .normal
        case "bold": self = .bold
        case "bolder": self = .bolder
        case "lighter": self = .lighter
        case let string:
            guard let number = Int(string) else {
                return nil
            }
            self = .number(number)
        }
    }

    public var svgString: String {
        switch self {
        case .normal: "normal"
        case .bold: "bold"
        case .bolder: "bolder"
        case .lighter: "lighter"
        case let .number(number): String(number)
        }
    }

}

public enum SVGFontStyle: String, Hashable {

    case normal
    case italic

    public var isItalic: Bool {
        self == .italic
    }

}
