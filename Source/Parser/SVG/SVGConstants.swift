// MIT license
// Derived from https://github.com/exyte/SVGView

import Foundation

enum SVGConstants {

    static let availableStyleAttributes = [
        "stroke",
        "stroke-width",
        "stroke-opacity",
        "stroke-dasharray",
        "stroke-dashoffset",
        "stroke-linecap",
        "stroke-linejoin",
        "stroke-miterlimit",
        "fill",
        "fill-rule",
    ]

}

public enum SVGParserRegexHelper {

    static let transformMatcher = try! NSRegularExpression(pattern: "\\-?\\d+\\.?\\d*e?\\-?\\d*", options: .caseInsensitive)
    static let transformAttributeMatcher = try! NSRegularExpression(pattern: "([a-z]+)\\(((\\-?\\d+\\.?\\d*e?\\-?\\d*\\s*,?\\s*)+)\\)", options: .caseInsensitive)

}
