// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation

extension SVGHelper {

    static func parseDouble(_ attributes: [String: String], _ key: String, defaultValue: Double = 0) -> Double {
        if let value = attributes[key], let result = doubleFromString(value) {
            return result
        }
        return defaultValue
    }

    static func parseCGFloat(_ attributes: [String: String], _ key: String, defaultValue: CGFloat = 0) -> CGFloat {
        if let value = attributes[key], let result = doubleFromString(value) {
            return CGFloat(result)
        }
        return defaultValue
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

    static func parseFill(_ style: [String: String]) -> SVGPaint? {
        style["fill"].map { parseColor($0).map { SVGPaint.color($0) } } ?? .none
    }

    static func parseStrokeFill(_ style: [String: String]) -> SVGPaint? {
        style["stroke"].map { parseColor($0).map { SVGPaint.color($0) } } ?? .none
    }

    static func parseColor(_ string: String) -> SVGColor? {
        let normalized = string.replacingOccurrences(of: " ", with: "")
        if normalized == "none" {
            return .none
        } else if let namedColor = SVGColor.by(name: normalized) {
            return namedColor
        } else {
            return createColorFromHex(normalized)
        }
    }

    static func createColorFromHex(_ hexString: String) -> SVGColor {
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            cleanedHexString = hexString.replacingOccurrences(of: "#", with: "")
        }
        if cleanedHexString.count == 3 {
            let x = Array(cleanedHexString)
            cleanedHexString = "\(x[0])\(x[0])\(x[1])\(x[1])\(x[2])\(x[2])"
        }
        return SVGColor(hex: cleanedHexString)
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
