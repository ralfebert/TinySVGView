// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation

public struct SVGColor: Equatable, Hashable {

    public static let black = SVGColor(0)
    public static let white = SVGColor(0xFFFFFF)
    public static let clear = SVGColor(r: 0, g: 0, b: 0, opacity: 0)

    public static func by(name: String) -> SVGColor? {
        SVGNamedColors.color(forName: name.lowercased())
    }

    public let value: Int

    /// How the color was written in the document, e.g. "steelblue", "#333" or "#fdf6e3". Colors
    /// created in code don't have one and are written out as a hex value or a color name.
    public let literal: String?

    public init(_ value: Int = 0, literal: String? = nil) {
        self.value = value
        self.literal = literal
    }

    public init(r: Int, g: Int, b: Int, t: Int = 0) {
        let x = (t & 0xFF) << 24
        let y = (r & 0xFF) << 16
        let z = (g & 0xFF) << 8
        let q = b & 0xFF
        self.init(x | y | z | q)
    }

    public init(r: Int, g: Int, b: Int, opacity: Double) {
        self.init(r: r, g: g, b: b, t: Int((1 - opacity) * 255))
    }

    public init(hex: String, literal: String? = nil) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(Int(rgbValue), literal: literal)
    }

    public var r: Int {
        (value >> 16) & 0xFF
    }

    public var g: Int {
        (value >> 8) & 0xFF
    }

    public var b: Int {
        value & 0xFF
    }

    var a: Int {
        255 - t
    }

    var t: Int {
        (value >> 24) & 0xFF
    }

    public var opacity: Double {
        Double(a) / 255
    }

    public var cgColor: CGColor {
        CGColor(red: CGFloat(r) / 0xFF, green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: CGFloat(opacity))
    }

    public var stringValue: String {
        literal ?? SVGNamedColors.name(forColor: value) ?? "#" + String(format: "%02X%02X%02X", r, g, b)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

/// The spelling is not part of the identity of a color.
public func == (lhs: SVGColor, rhs: SVGColor) -> Bool {
    lhs.value == rhs.value
}

final class SVGNamedColors {

    static func color(forName name: String) -> SVGColor? {
        instance.hexByText[name].map { SVGColor($0, literal: name) }
    }

    static func name(forColor hex: Int) -> String? {
        instance.textByHex[hex]
    }

    private static let instance = SVGNamedColors()

    private var hexByText = [String: Int]()
    private var textByHex = [Int: String]()

    private init() {
        add(text: "white", hex: 0xFFFFFF)
        add(text: "silver", hex: 0xC0C0C0)
        add(text: "gray", hex: 0x808080)
        add(text: "black", hex: 0)
        add(text: "red", hex: 0xFF0000)
        add(text: "maroon", hex: 0x800000)
        add(text: "yellow", hex: 0xFFFF00)
        add(text: "olive", hex: 0x808000)
        add(text: "lime", hex: 0x00FF00)
        add(text: "green", hex: 0x008000)
        add(text: "aqua", hex: 0x00FFFF)
        add(text: "teal", hex: 0x008080)
        add(text: "blue", hex: 0x0000FF)
        add(text: "navy", hex: 0x000080)
        add(text: "fuchsia", hex: 0xFF00FF)
        add(text: "purple", hex: 0x800080)

        add(text: "aliceblue", hex: 0xF0F8FF)
        add(text: "antiquewhite", hex: 0xFAEBD7)
        add(text: "aquamarine", hex: 0x7FFFD4)
        add(text: "azure", hex: 0xF0FFFF)
        add(text: "beige", hex: 0xF5F5DC)
        add(text: "bisque", hex: 0xFFE4C4)
        add(text: "blanchedalmond", hex: 0xFFEBCD)
        add(text: "blueviolet", hex: 0x8A2BE2)
        add(text: "brown", hex: 0xA52A2A)
        add(text: "burlywood", hex: 0xDEB887)
        add(text: "cadetblue", hex: 0x5F9EA0)
        add(text: "chartreuse", hex: 0x7FFF00)
        add(text: "chocolate", hex: 0xD2691E)
        add(text: "coral", hex: 0xFF7F50)
        add(text: "cornflowerblue", hex: 0x6495ED)
        add(text: "cornsilk", hex: 0xFFF8DC)
        add(text: "crimson", hex: 0xDC143C)
        // cyan equals to aqua
        add(text: "cyan", hex: 0x00FFFF, isKey: false)
        add(text: "darkblue", hex: 0x00008B)
        add(text: "darkcyan", hex: 0x008B8B)
        add(text: "darkgoldenrod", hex: 0xB8860B)
        add(text: "darkgray", hex: 0xA9A9A9)
        add(text: "darkgreen", hex: 0x006400)
        add(text: "darkkhaki", hex: 0xBDB76B)
        add(text: "darkmagenta", hex: 0x8B008B)
        add(text: "darkolivegreen", hex: 0x556B2F)
        add(text: "darkorange", hex: 0xFF8C00)
        add(text: "darkorchid", hex: 0x9932CC)
        add(text: "darkred", hex: 0x8B0000)
        add(text: "darksalmon", hex: 0xE9967A)
        add(text: "darkseagreen", hex: 0x8FBC8F)
        add(text: "darkslateblue", hex: 0x483D8B)
        add(text: "darkslategray", hex: 0x2F4F4F)
        add(text: "darkturquoise", hex: 0x00CED1)
        add(text: "darkviolet", hex: 0x9400D3)
        add(text: "deeppink", hex: 0xFF1493)
        add(text: "deepskyblue", hex: 0x00BFFF)
        add(text: "dimgray", hex: 0x696969)
        add(text: "dodgerblue", hex: 0x1E90FF)
        add(text: "firebrick", hex: 0xB22222)
        add(text: "floralwhite", hex: 0xFFFAF0)
        add(text: "forestgreen", hex: 0x228B22)
        add(text: "gainsboro", hex: 0xDCDCDC)
        add(text: "ghostwhite", hex: 0xF8F8FF)
        add(text: "gold", hex: 0xFFD700)
        add(text: "goldenrod", hex: 0xDAA520)
        add(text: "greenyellow", hex: 0xADFF2F)
        add(text: "honeydew", hex: 0xF0FFF0)
        add(text: "hotpink", hex: 0xFF69B4)
        add(text: "indianred", hex: 0xCD5C5C)
        add(text: "indigo", hex: 0x4B0082)
        add(text: "ivory", hex: 0xFFFFF0)
        add(text: "khaki", hex: 0xF0E68C)
        add(text: "lavender", hex: 0xE6E6FA)
        add(text: "lavenderblush", hex: 0xFFF0F5)
        add(text: "lawngreen", hex: 0x7CFC00)
        add(text: "lemonchiffon", hex: 0xFFFACD)
        add(text: "lightblue", hex: 0xADD8E6)
        add(text: "lightcoral", hex: 0xF08080)
        add(text: "lightcyan", hex: 0xE0FFFF)
        add(text: "lightgoldenrodyellow", hex: 0xFAFAD2)
        add(text: "lightgray", hex: 0xD3D3D3)
        add(text: "lightgreen", hex: 0x90EE90)
        add(text: "lightpink", hex: 0xFFB6C1)
        add(text: "lightsalmon", hex: 0xFFA07A)
        add(text: "lightseagreen", hex: 0x20B2AA)
        add(text: "lightskyblue", hex: 0x87CEFA)
        add(text: "lightslategray", hex: 0x778899)
        add(text: "lightsteelblue", hex: 0xB0C4DE)
        add(text: "lightyellow", hex: 0xFFFFE0)
        add(text: "limegreen", hex: 0x32CD32)
        add(text: "linen", hex: 0xFAF0E6)
        add(text: "mediumaquamarine", hex: 0x66CDAA)
        add(text: "mediumblue", hex: 0x0000CD)
        add(text: "mediumorchid", hex: 0xBA55D3)
        add(text: "mediumpurple", hex: 0x9370DB)
        add(text: "mediumseagreen", hex: 0x3CB371)
        add(text: "mediumslateblue", hex: 0x7B68EE)
        add(text: "mediumspringgreen", hex: 0x00FA9A)
        add(text: "mediumturquoise", hex: 0x48D1CC)
        add(text: "mediumvioletred", hex: 0xC71585)
        add(text: "midnightblue", hex: 0x191970)
        add(text: "mintcream", hex: 0xF5FFFA)
        add(text: "mistyrose", hex: 0xFFE4E1)
        add(text: "moccasin", hex: 0xFFE4B5)
        add(text: "navajowhite", hex: 0xFFDEAD)
        add(text: "oldlace", hex: 0xFDF5E6)
        add(text: "olivedrab", hex: 0x6B8E23)
        add(text: "orange", hex: 0xFFA500)
        add(text: "orangered", hex: 0xFF4500)
        add(text: "orchid", hex: 0xDA70D6)
        add(text: "palegoldenrod", hex: 0xEEE8AA)
        add(text: "palegreen", hex: 0x98FB98)
        add(text: "paleturquoise", hex: 0xAFEEEE)
        add(text: "palevioletred", hex: 0xDB7093)
        add(text: "papayawhip", hex: 0xFFEFD5)
        add(text: "peachpuff", hex: 0xFFDAB9)
        add(text: "peru", hex: 0xCD853F)
        add(text: "pink", hex: 0xFFC0CB)
        add(text: "plum", hex: 0xDDA0DD)
        add(text: "powderblue", hex: 0xB0E0E6)
        add(text: "rebeccapurple", hex: 0x663399)
        add(text: "rosybrown", hex: 0xBC8F8F)
        add(text: "royalblue", hex: 0x4169E1)
        add(text: "saddlebrown", hex: 0x8B4513)
        add(text: "salmon", hex: 0xFA8072)
        add(text: "sandybrown", hex: 0xF4A460)
        add(text: "seagreen", hex: 0x2E8B57)
        add(text: "seashell", hex: 0xFFF5EE)
        add(text: "sienna", hex: 0xA0522D)
        add(text: "skyblue", hex: 0x87CEEB)
        add(text: "slateblue", hex: 0x6A5ACD)
        add(text: "slategray", hex: 0x708090)
        add(text: "snow", hex: 0xFFFAFA)
        add(text: "springgreen", hex: 0x00FF7F)
        add(text: "steelblue", hex: 0x4682B4)
        add(text: "tan", hex: 0xD2B48C)
        add(text: "thistle", hex: 0xD8BFD8)
        add(text: "tomato", hex: 0xFF6347)
        add(text: "turquoise", hex: 0x40E0D0)
        add(text: "violet", hex: 0xEE82EE)
        add(text: "wheat", hex: 0xF5DEB3)
        add(text: "whitesmoke", hex: 0xF5F5F5)
        add(text: "yellowgreen", hex: 0x9ACD32)
    }

    private func add(text: String, hex: Int, isKey: Bool = true) {
        hexByText[text] = hex
        if isKey {
            textByHex[hex] = text
        }
    }

}
