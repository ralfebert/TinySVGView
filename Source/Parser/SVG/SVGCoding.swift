// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation
import XMLCoder

// MARK: - Coding keys

/// An XML attribute name or the element's text content (the empty key).
struct SVGCodingKey: CodingKey {

    let stringValue: String
    var intValue: Int? {
        nil
    }

    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue _: Int) {
        nil
    }

    /// The element's text content, e.g. the "abc" in `<text>abc</text>`.
    static let content = SVGCodingKey("")

}

/// A child element name. XMLCoder decodes a heterogenous list of child elements into an array of
/// `SVGElement` when the keys are marked as a choice.
struct SVGElementKey: XMLChoiceCodingKey {

    let stringValue: String
    var intValue: Int? {
        nil
    }

    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue _: Int) {
        nil
    }

    static let g = SVGElementKey("g")
    static let path = SVGElementKey("path")
    static let rect = SVGElementKey("rect")
    static let circle = SVGElementKey("circle")
    static let ellipse = SVGElementKey("ellipse")
    static let line = SVGElementKey("line")
    static let polyline = SVGElementKey("polyline")
    static let polygon = SVGElementKey("polygon")
    static let text = SVGElementKey("text")

    static let all = [g, path, rect, circle, ellipse, line, polyline, polygon, text]

    /// The keys that are written as child elements rather than as attributes; the empty key is the
    /// text content of `<text>`.
    static let elementNames: Set<String> = all.map(\.stringValue).reduce(into: [""]) { $0.insert($1) }

}

/// One child element of a group or of the viewport.
enum SVGElement {

    case g(SVGGroup)
    case path(SVGPath)
    case rect(SVGRect)
    case circle(SVGCircle)
    case ellipse(SVGEllipse)
    case line(SVGLine)
    case polyline(SVGPolyline)
    case polygon(SVGPolygon)
    case text(SVGText)
    /// An element TinySVGView doesn't support; kept so the surrounding siblings still decode.
    case unsupported(String)

    init?(_ node: SVGNode) {
        switch node {
        case let node as SVGGroup: self = .g(node)
        case let node as SVGPath: self = .path(node)
        case let node as SVGRect: self = .rect(node)
        case let node as SVGCircle: self = .circle(node)
        case let node as SVGEllipse: self = .ellipse(node)
        case let node as SVGLine: self = .line(node)
        case let node as SVGPolyline: self = .polyline(node)
        case let node as SVGPolygon: self = .polygon(node)
        case let node as SVGText: self = .text(node)
        default: return nil
        }
    }

    var node: SVGNode? {
        switch self {
        case let .g(node): node
        case let .path(node): node
        case let .rect(node): node
        case let .circle(node): node
        case let .ellipse(node): node
        case let .line(node): node
        case let .polyline(node): node
        case let .polygon(node): node
        case let .text(node): node
        case .unsupported: nil
        }
    }

}

extension SVGElement: Codable {

    typealias CodingKeys = SVGElementKey

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SVGElementKey.self)
        switch container.allKeys.first?.stringValue {
        case SVGElementKey.g.stringValue:
            self = try .g(container.decode(SVGGroup.self, forKey: .g))
        case SVGElementKey.path.stringValue:
            self = try .path(container.decode(SVGPath.self, forKey: .path))
        case SVGElementKey.rect.stringValue:
            self = try .rect(container.decode(SVGRect.self, forKey: .rect))
        case SVGElementKey.circle.stringValue:
            self = try .circle(container.decode(SVGCircle.self, forKey: .circle))
        case SVGElementKey.ellipse.stringValue:
            self = try .ellipse(container.decode(SVGEllipse.self, forKey: .ellipse))
        case SVGElementKey.line.stringValue:
            self = try .line(container.decode(SVGLine.self, forKey: .line))
        case SVGElementKey.polyline.stringValue:
            self = try .polyline(container.decode(SVGPolyline.self, forKey: .polyline))
        case SVGElementKey.polygon.stringValue:
            self = try .polygon(container.decode(SVGPolygon.self, forKey: .polygon))
        case SVGElementKey.text.stringValue:
            self = try .text(container.decode(SVGText.self, forKey: .text))
        case let name:
            self = .unsupported(name ?? "")
            decoder.svgLogger.log(message: "Skipping unsupported element: \(name ?? "")")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGElementKey.self)
        switch self {
        case let .g(node): try container.encode(node, forKey: .g)
        case let .path(node): try container.encode(node, forKey: .path)
        case let .rect(node): try container.encode(node, forKey: .rect)
        case let .circle(node): try container.encode(node, forKey: .circle)
        case let .ellipse(node): try container.encode(node, forKey: .ellipse)
        case let .line(node): try container.encode(node, forKey: .line)
        case let .polyline(node): try container.encode(node, forKey: .polyline)
        case let .polygon(node): try container.encode(node, forKey: .polygon)
        case let .text(node): try container.encode(node, forKey: .text)
        case .unsupported: break
        }
    }

}

// MARK: - Attributes

extension Decoder {

    /// All attributes of the current element, in the flat form the `SVGHelper` parsers work on.
    /// Child element names end up in here as well, which is harmless as long as no SVG attribute
    /// shares a name with an SVG element.
    func svgAttributes() throws -> [String: String] {
        let container = try self.container(keyedBy: SVGCodingKey.self)
        var attributes = [String: String]()
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                attributes[key.stringValue] = value
            }
        }
        return attributes
    }

    /// The supported child elements; unsupported ones are dropped.
    func svgContents() throws -> [SVGNode] {
        guard let elements = try? singleValueContainer().decode([SVGElement].self) else {
            return []
        }
        return elements.compactMap(\.node)
    }

    var svgLogger: SVGLogger {
        userInfo[.svgLogger] as? SVGLogger ?? .console
    }

}

extension CodingUserInfoKey {
    static let svgLogger = CodingUserInfoKey(rawValue: "svgLogger")!
}

extension SVGNode {

    mutating func decodeBasicAttributes(_ attributes: [String: String]) {
        transform = transform.concatenating(SVGHelper.parseTransform(attributes["transform"] ?? ""))
        opacity = SVGHelper.parseOpacity(attributes, "opacity")
        id = attributes["id"]
    }

    func encodeBasicAttributes(to container: inout KeyedEncodingContainer<SVGCodingKey>) throws {
        if let id {
            try container.encode(id, forKey: SVGCodingKey("id"))
        }
        if transform != .identity {
            try container.encode(transform.svgString, forKey: SVGCodingKey("transform"))
        }
        if opacity != 1 {
            try container.encode(opacity.svgString, forKey: SVGCodingKey("opacity"))
        }
    }

}

extension SVGShape {

    mutating func decodePaintAttributes(_ attributes: [String: String]) {
        fill = SVGHelper.parsePaint(attributes, "fill")
        stroke = SVGHelper.parseStroke(attributes)
    }

    /// Writes `fill` and the `stroke-*` family.
    func encodePaintAttributes(to container: inout KeyedEncodingContainer<SVGCodingKey>) throws {
        switch fill {
        case .unspecified:
            break
        case .none:
            try container.encode("none", forKey: SVGCodingKey("fill"))
        case let .color(color):
            try container.encode(color.stringValue, forKey: SVGCodingKey("fill"))
        }

        guard let stroke else {
            return
        }
        if case let .color(color) = stroke.fill {
            try container.encode(color.stringValue, forKey: SVGCodingKey("stroke"))
        }
        if stroke.width != 1 {
            try container.encode(stroke.width.svgString, forKey: SVGCodingKey("stroke-width"))
        }
        if stroke.cap != .butt {
            try container.encode(stroke.cap.svgString, forKey: SVGCodingKey("stroke-linecap"))
        }
        if stroke.join != .miter {
            try container.encode(stroke.join.svgString, forKey: SVGCodingKey("stroke-linejoin"))
        }
        if stroke.miterLimit != 4 {
            try container.encode(stroke.miterLimit.svgString, forKey: SVGCodingKey("stroke-miterlimit"))
        }
        if !stroke.dashes.isEmpty {
            try container.encode(stroke.dashes.map(\.svgString).joined(separator: " "), forKey: SVGCodingKey("stroke-dasharray"))
        }
        if stroke.offset != 0 {
            try container.encode(stroke.offset.svgString, forKey: SVGCodingKey("stroke-dashoffset"))
        }
    }

}

private extension SVGNodeContainer {

    func encodeContents(to encoder: Encoder) throws {
        for node in contents {
            guard let element = SVGElement(node) else {
                throw EncodingError.invalidValue(node, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported node type: \(type(of: node))"))
            }
            try element.encode(to: encoder)
        }
    }

}

// MARK: - Elements

extension SVGViewport: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        try self.init(
            width: SVGHelper.parseCGFloat(attributes, "width"),
            height: SVGHelper.parseCGFloat(attributes, "height"),
            preserveAspectRatio: SVGPreserveAspectRatio.parsePreserveAspectRatio(string: attributes["preserveAspectRatio"]),
            contents: decoder.svgContents()
        )
        decodeBasicAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode("http://www.w3.org/2000/svg", forKey: SVGCodingKey("xmlns"))
        try container.encode(width.svgString, forKey: SVGCodingKey("width"))
        try container.encode(height.svgString, forKey: SVGCodingKey("height"))
        if preserveAspectRatio != SVGPreserveAspectRatio() {
            try container.encode(preserveAspectRatio.svgString, forKey: SVGCodingKey("preserveAspectRatio"))
        }
        try encodeBasicAttributes(to: &container)
        try encodeContents(to: encoder)
    }

}

extension SVGGroup: Codable {

    public init(from decoder: Decoder) throws {
        try self.init(contents: decoder.svgContents())
        try decodeBasicAttributes(decoder.svgAttributes())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try encodeBasicAttributes(to: &container)
        try encodeContents(to: encoder)
    }

}

extension SVGPath: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            segments: PathReader(input: attributes["d"] ?? "").read(),
            fillRule: SVGHelper.parseFillRule(attributes)
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(segments.svgString, forKey: SVGCodingKey("d"))
        try container.encodeFillRule(fillRule)
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGRect: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            x: SVGHelper.parseCGFloat(attributes, "x"),
            y: SVGHelper.parseCGFloat(attributes, "y"),
            width: SVGHelper.parseCGFloat(attributes, "width"),
            height: SVGHelper.parseCGFloat(attributes, "height"),
            rx: SVGHelper.parseCGFloat(attributes, "rx"),
            ry: SVGHelper.parseCGFloat(attributes, "ry")
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        if x != 0 {
            try container.encode(x.svgString, forKey: SVGCodingKey("x"))
        }
        if y != 0 {
            try container.encode(y.svgString, forKey: SVGCodingKey("y"))
        }
        if width != 0 {
            try container.encode(width.svgString, forKey: SVGCodingKey("width"))
        }
        if height != 0 {
            try container.encode(height.svgString, forKey: SVGCodingKey("height"))
        }
        if rx != 0 {
            try container.encode(rx.svgString, forKey: SVGCodingKey("rx"))
        }
        if ry != 0 {
            try container.encode(ry.svgString, forKey: SVGCodingKey("ry"))
        }
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGCircle: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            cx: SVGHelper.parseCGFloat(attributes, "cx"),
            cy: SVGHelper.parseCGFloat(attributes, "cy"),
            r: SVGHelper.parseCGFloat(attributes, "r")
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(cx.svgString, forKey: SVGCodingKey("cx"))
        try container.encode(cy.svgString, forKey: SVGCodingKey("cy"))
        try container.encode(r.svgString, forKey: SVGCodingKey("r"))
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGEllipse: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            cx: SVGHelper.parseCGFloat(attributes, "cx"),
            cy: SVGHelper.parseCGFloat(attributes, "cy"),
            rx: SVGHelper.parseCGFloat(attributes, "rx"),
            ry: SVGHelper.parseCGFloat(attributes, "ry")
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(cx.svgString, forKey: SVGCodingKey("cx"))
        try container.encode(cy.svgString, forKey: SVGCodingKey("cy"))
        try container.encode(rx.svgString, forKey: SVGCodingKey("rx"))
        try container.encode(ry.svgString, forKey: SVGCodingKey("ry"))
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGLine: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            x1: SVGHelper.parseCGFloat(attributes, "x1"),
            y1: SVGHelper.parseCGFloat(attributes, "y1"),
            x2: SVGHelper.parseCGFloat(attributes, "x2"),
            y2: SVGHelper.parseCGFloat(attributes, "y2")
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(x1.svgString, forKey: SVGCodingKey("x1"))
        try container.encode(x2.svgString, forKey: SVGCodingKey("x2"))
        try container.encode(y1.svgString, forKey: SVGCodingKey("y1"))
        try container.encode(y2.svgString, forKey: SVGCodingKey("y2"))
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGPolyline: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(points: SVGHelper.parsePoints(attributes), fillRule: SVGHelper.parseFillRule(attributes))
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(points.svgString, forKey: SVGCodingKey("points"))
        try container.encodeFillRule(fillRule)
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGPolygon: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(points: SVGHelper.parsePoints(attributes), fillRule: SVGHelper.parseFillRule(attributes))
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(points.svgString, forKey: SVGCodingKey("points"))
        try container.encodeFillRule(fillRule)
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
    }

}

extension SVGText: Codable {

    public init(from decoder: Decoder) throws {
        let attributes = try decoder.svgAttributes()
        self.init(
            text: attributes[SVGCodingKey.content.stringValue]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            font: SVGFont(
                family: attributes["font-family"] ?? SVGFont().family,
                size: SVGHelper.parseFontSize(attributes, defaultValue: SVGFont().size),
                weight: attributes["font-weight"].flatMap { SVGFontWeight(parsing: $0) } ?? SVGFont().weight,
                style: attributes["font-style"].flatMap { SVGFontStyle(rawValue: $0) } ?? SVGFont().style
            ),
            anchor: Anchor(rawValue: attributes["text-anchor"] ?? "") ?? .start,
            x: SVGHelper.parseCGFloat(attributes, "x"),
            y: SVGHelper.parseCGFloat(attributes, "y")
        )
        decodeBasicAttributes(attributes)
        decodePaintAttributes(attributes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SVGCodingKey.self)
        try container.encode(x.svgString, forKey: SVGCodingKey("x"))
        try container.encode(y.svgString, forKey: SVGCodingKey("y"))
        if font.family != SVGFont().family {
            try container.encode(font.family, forKey: SVGCodingKey("font-family"))
        }
        if font.size != SVGFont().size {
            try container.encode(font.size.svgString, forKey: SVGCodingKey("font-size"))
        }
        if font.weight != SVGFont().weight {
            try container.encode(font.weight.svgString, forKey: SVGCodingKey("font-weight"))
        }
        if font.style != SVGFont().style {
            try container.encode(font.style.rawValue, forKey: SVGCodingKey("font-style"))
        }
        if anchor != .start {
            try container.encode(anchor.rawValue, forKey: SVGCodingKey("text-anchor"))
        }
        try encodeBasicAttributes(to: &container)
        try encodePaintAttributes(to: &container)
        try container.encode(text, forKey: .content)
    }

}

// MARK: - Attribute values

extension KeyedEncodingContainer<SVGCodingKey> {

    mutating func encodeFillRule(_ fillRule: CGPathFillRule) throws {
        if fillRule == .evenOdd {
            try encode("evenodd", forKey: SVGCodingKey("fill-rule"))
        }
    }

}

extension [CGPoint] {

    var svgString: String {
        map { "\($0.x.svgString) \($0.y.svgString)" }.joined(separator: " ")
    }

}

extension SVGLength {

    var svgString: String {
        number.svgString + unit.rawValue
    }

}

extension BinaryFloatingPoint {

    /// The shortest representation that reads back as the same value.
    var svgString: String {
        let value = Double(self)
        return value.rounded() == value && abs(value) < 1e15 ? String(Int(value)) : String(value)
    }

}

extension CGAffineTransform {

    /// The simplest operation that produces this matrix. A document that combines operations, or
    /// rotates around a point, comes back out as a `matrix()`.
    var svgString: String {
        if a == 1, b == 0, c == 0, d == 1 {
            return "translate(\(tx.svgString),\(ty.svgString))"
        }
        if b == 0, c == 0, tx == 0, ty == 0 {
            return "scale(\(a.svgString),\(d.svgString))"
        }
        if a == d, b == -c, tx == 0, ty == 0, abs(a * a + b * b - 1) < 1e-12 {
            return "rotate(\((atan2(b, a) * 180 / .pi).svgString))"
        }
        return "matrix(\(a.svgString),\(b.svgString),\(c.svgString),\(d.svgString),\(tx.svgString),\(ty.svgString))"
    }

}

extension [PathSegment] {

    var svgString: String {
        map { "\($0.type.rawValue)\($0.data.map(\.svgString).joined(separator: " "))" }.joined(separator: " ")
    }

}

extension SVGPreserveAspectRatio: Equatable {

    var svgString: String {
        if scaling == .none {
            return "none"
        }
        return "x\(xAlign.svgString)Y\(yAlign.svgString) \(scaling.rawValue)"
    }

    public static func == (lhs: SVGPreserveAspectRatio, rhs: SVGPreserveAspectRatio) -> Bool {
        lhs.scaling == rhs.scaling && lhs.xAlign == rhs.xAlign && lhs.yAlign == rhs.yAlign
    }

}

private extension SVGPreserveAspectRatio.Align {

    var svgString: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

}

private extension CGLineCap {

    var svgString: String {
        switch self {
        case .round: "round"
        case .square: "square"
        default: "butt"
        }
    }

}

private extension CGLineJoin {

    var svgString: String {
        switch self {
        case .round: "round"
        case .bevel: "bevel"
        default: "miter"
        }
    }

}
