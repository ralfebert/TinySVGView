// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation

public enum SVGHelper {

    /// A stroke is only created for an explicit `stroke` color; `stroke="none"` and a missing
    /// `stroke` both mean the shape isn't stroked.
    static func parseStroke(_ style: [String: String]) -> SVGStroke? {
        guard case let .color(color) = parsePaint(style, "stroke") else {
            return .none
        }

        return SVGStroke(
            fill: .color(color),
            width: parseCGFloat(style, "stroke-width", defaultValue: 1),
            cap: getStrokeCap(style),
            join: getStrokeJoin(style),
            miterLimit: parseCGFloat(style, "stroke-miterlimit", defaultValue: 4),
            dashes: getStrokeDashes(style),
            offset: parseCGFloat(style, "stroke-dashoffset")
        )
    }

    static func getStrokeDashes(_ style: [String: String]) -> [CGFloat] {
        guard let dashes = style["stroke-dasharray"] else {
            return []
        }
        return dashes.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { SVGLength(parsing: $0)?.value }
    }

    static func getStrokeCap(_ style: [String: String]) -> CGLineCap {
        if let strokeCap = style["stroke-linecap"] {
            switch strokeCap {
            case "round":
                return .round
            case "square":
                return .square
            default:
                break
            }
        }
        return .butt
    }

    static func getStrokeJoin(_ style: [String: String]) -> CGLineJoin {
        if let strokeJoin = style["stroke-linejoin"] {
            switch strokeJoin {
            case "round":
                return .round
            case "bevel":
                return .bevel
            default:
                break
            }
        }
        return .miter
    }

    static func parseTransform(_ attributes: String, transform: CGAffineTransform = CGAffineTransform.identity) -> CGAffineTransform {
        let attributes = attributes.replacing("\n", with: "")
        var finalTransform = transform
        let fullRange = NSRange(location: 0, length: attributes.count)

        guard let matchedAttribute = SVGParserRegexHelper.transformAttributeMatcher.firstMatch(in: attributes, options: .reportCompletion, range: fullRange) else {
            return finalTransform
        }
        let attributeName = (attributes as NSString).substring(with: matchedAttribute.range(at: 1))
        let values = parseTransformValues((attributes as NSString).substring(with: matchedAttribute.range(at: 2)))
        if values.isEmpty {
            return finalTransform
        }
        switch attributeName {
        case "translate":
            if let x = values[0].cgFloatValue {
                var y: CGFloat = 0
                if values.indices.contains(1) {
                    y = values[1].cgFloatValue ?? 0
                }
                finalTransform = finalTransform.translatedBy(x: x, y: y)
            }
        case "scale":
            if let x = values[0].cgFloatValue {
                var y = x
                if values.indices.contains(1) {
                    y = values[1].cgFloatValue ?? x
                }
                finalTransform = finalTransform.scaledBy(x: x, y: y)
            }
        case "rotate":
            if let angle = values[0].cgFloatValue {
                if values.count == 1 {
                    finalTransform = finalTransform.rotated(by: angle.degreesToRadians)
                } else if values.count == 3 {
                    if let x = values[1].cgFloatValue, let y = values[2].cgFloatValue {
                        finalTransform = finalTransform.translatedBy(x: x, y: y).rotated(by: angle.degreesToRadians).translatedBy(x: -x, y: -y)
                    }
                }
            }
        case "skewX":
            if let x = values[0].cgFloatValue {
                let v = tan((x * .pi) / 180.0)
                finalTransform = finalTransform.shear(shx: v, shy: 0)
            }
        case "skewY":
            if let y = values[0].cgFloatValue {
                let y = tan((y * .pi) / 180.0)
                finalTransform = finalTransform.shear(shx: 0, shy: y)
            }
        case "matrix":
            if values.count != 6 {
                return finalTransform
            }
            if let a = values[0].cgFloatValue, let b = values[1].cgFloatValue,
               let c = values[2].cgFloatValue, let d = values[3].cgFloatValue,
               let tx = values[4].cgFloatValue, let ty = values[5].cgFloatValue
            {

                let transformMatrix = CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
                finalTransform = finalTransform.concatenating(transformMatrix)
            }
        default:
            break
        }
        let rangeToRemove = NSRange(location: 0,
                                    length: matchedAttribute.range.location + matchedAttribute.range.length)
        let newAttributeString = (attributes as NSString).replacingCharacters(in: rangeToRemove, with: "")
        return parseTransform(newAttributeString, transform: finalTransform)
    }

    static func parseTransformValues(_ values: String, collectedValues: [String] = []) -> [String] {
        var updatedValues: [String] = collectedValues
        let fullRange = NSRange(location: 0, length: values.count)
        if let matchedValue = SVGParserRegexHelper.transformMatcher.firstMatch(in: values, options: .reportCompletion, range: fullRange) {
            let value = (values as NSString).substring(with: matchedValue.range)
            updatedValues.append(value)
            let rangeToRemove = NSRange(location: 0, length: matchedValue.range.location + matchedValue.range.length)
            let newValues = (values as NSString).replacingCharacters(in: rangeToRemove, with: "")
            return parseTransformValues(newValues, collectedValues: updatedValues)
        }
        return updatedValues
    }

}
