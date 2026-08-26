// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation
import WebColor

extension SVGHelper {

    static func parseDouble(_ attributes: [String: String], _ key: String, defaultValue: Double = 0) -> Double {
        if let value = attributes[key], let result = doubleFromString(value) {
            return result
        }
        return defaultValue
    }

    /// A length attribute. A unit is converted to user units, e.g. `stroke-width="1.5pt"` reads as 2.
    static func parseCGFloat(_ attributes: [String: String], _ key: String, defaultValue: CGFloat = 0) -> CGFloat {
        attributes[key].flatMap { SVGLength(parsing: $0) }?.value ?? defaultValue
    }

    /// The one length that keeps its unit, so that `font-size="12pt"` is written back as `12pt`.
    static func parseFontSize(_ attributes: [String: String], defaultValue: SVGLength) -> SVGLength {
        attributes["font-size"].flatMap { SVGLength(parsing: $0) } ?? defaultValue
    }

    static func doubleFromString(_ string: String) -> Double? {
        if string == "none" {
            return 0
        }

        return Double(string)
    }

    static func parseOpacity(_ attributes: [String: String], _ key: String) -> Double {
        let opacity = parseDouble(attributes, key, defaultValue: 1)
        return min(max(opacity, 0), 1)
    }

    static func parseFillRule(_ attributes: [String: String]) -> CGPathFillRule {
        attributes["fill-rule"] == "evenodd" ? .evenOdd : .winding
    }

    /// The `points` of a polyline or polygon, e.g. "60 110, 65 120".
    static func parsePoints(_ attributes: [String: String]) -> [CGPoint] {
        let numbers = (attributes["points"] ?? "")
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ",")))
            .compactMap { Double($0) }
        return stride(from: 0, to: numbers.count - 1, by: 2).map { CGPoint(x: numbers[$0], y: numbers[$0 + 1]) }
    }

    static func parsePaint(_ style: [String: String], _ key: String) -> SVGPaint {
        guard let value = style[key] else {
            return .unspecified
        }
        return parseColor(value).map { SVGPaint.color($0) } ?? SVGPaint.noPaint
    }

    static func parseColor(_ string: String) -> WrittenWebColor? {
        WrittenWebColor(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }

}

extension SVGPreserveAspectRatio {

    static func parsePreserveAspectRatio(string: String?) -> SVGPreserveAspectRatio {
        if let contentModeString = string {
            let strings = contentModeString.components(separatedBy: CharacterSet(charactersIn: " "))
            if strings.count == 1 { // none
                return SVGPreserveAspectRatio(scaling: parseScaling(strings[0]))
            }
            guard strings.count == 2 else {
                return SVGPreserveAspectRatio()
            }

            let alignString = strings[0]
            var xAlign = alignString.prefix(4).lowercased()
            xAlign.remove(at: xAlign.startIndex)
            let xAligningMode = parseAlign(xAlign)

            var yAlign = alignString.suffix(4).lowercased()
            yAlign.remove(at: yAlign.startIndex)
            let yAligningMode = parseAlign(yAlign)

            let scalingMode = parseScaling(strings[1])
            return SVGPreserveAspectRatio(scaling: scalingMode, xAlign: xAligningMode, yAlign: yAligningMode)
        }
        return SVGPreserveAspectRatio()
    }

    static func parseAlign(_ string: String) -> SVGPreserveAspectRatio.Align {
        switch string {
        case "min": .min
        case "max": .max
        default: .mid
        }
    }

    static func parseScaling(_ string: String) -> SVGPreserveAspectRatio.Scaling {
        switch string {
        case "meet": .meet
        case "slice": .slice
        default: .none
        }
    }

}
