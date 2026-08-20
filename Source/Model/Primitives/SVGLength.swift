// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation

/// A length as written in the document: the number plus the unit it was given in. Everything that
/// draws uses `value`, the length converted to user units; the unit is kept so that a document
/// written back out keeps the units it came with.
///
/// The relative units (`em`, `ex`, `%`) are not supported; an attribute using one is read as if it
/// wasn't there at all.
public struct SVGLength: Hashable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {

    public enum Unit: String, CaseIterable {
        /// A plain number, which in SVG is a user unit and identical to `px`.
        case userUnit = ""
        case px
        case pt
        case pc
        case inch = "in"
        case cm
        case mm

        /// User units per unit, following the CSS 96dpi definitions.
        public var scale: CGFloat {
            switch self {
            case .userUnit, .px: 1
            case .pt: 96.0 / 72.0
            case .pc: 16
            case .inch: 96
            case .cm: 96.0 / 2.54
            case .mm: 96.0 / 25.4
            }
        }
    }

    /// The number as written in the document.
    public var number: CGFloat
    public var unit: Unit

    /// The length in user units.
    public var value: CGFloat {
        number * unit.scale
    }

    public init(_ number: CGFloat, _ unit: Unit = .userUnit) {
        self.number = number
        self.unit = unit
    }

    public init(integerLiteral value: Int) {
        self.init(CGFloat(value))
    }

    public init(floatLiteral value: Double) {
        self.init(CGFloat(value))
    }

    /// Reads a number with an optional unit, e.g. "12", "-1.5e2", "12px", "2.5cm".
    public init?(parsing string: String) {
        let string = string.trimmingCharacters(in: .whitespaces)
        let unit = Unit.allCases.first { !$0.rawValue.isEmpty && string.hasSuffix($0.rawValue) } ?? .userUnit
        guard let number = Double(string.dropLast(unit.rawValue.count)) else {
            return nil
        }
        self.init(CGFloat(number), unit)
    }

}
