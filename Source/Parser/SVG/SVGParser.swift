// MIT license
// Derived from https://github.com/exyte/SVGView

import Foundation
import XMLCoder

public enum SVGParser {

    public static func parse(contentsOf url: URL, settings: SVGSettings = .default) -> SVGNode? {
        do {
            return try decode(data: Data(contentsOf: url), settings: settings)
        } catch {
            settings.logger.log(error: error)
            return nil
        }
    }

    public static func parse(string: String, settings: SVGSettings = .default) -> SVGNode? {
        parse(data: Data(string.utf8), settings: settings)
    }

    public static func parse(data: Data, settings: SVGSettings = .default) -> SVGNode? {
        do {
            return try decode(data: data, settings: settings)
        } catch {
            settings.logger.log(error: error)
            return nil
        }
    }

    /// Throws instead of logging, e.g. to tell a broken document from an empty one.
    public static func decode(data: Data, settings: SVGSettings = .default) throws -> SVGViewport {
        let decoder = XMLDecoder()
        decoder.userInfo[.svgLogger] = settings.logger
        return try decoder.decode(SVGViewport.self, from: data)
    }

}

public extension SVGViewport {

    func xmlData(prettyPrinted: Bool = true) throws -> Data {
        let encoder = XMLEncoder()
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted] : []
        // Everything an SVG element carries is an attribute, apart from its child elements.
        encoder.nodeEncodingStrategy = .custom { _, _ in
            { SVGElementKey.elementNames.contains($0.stringValue) ? .element : .attribute }
        }
        return try encoder.encode(self, withRootKey: "svg", header: XMLHeader(version: 1.0, encoding: "UTF-8"))
    }

    func xmlString(prettyPrinted: Bool = true) throws -> String {
        try String(decoding: xmlData(prettyPrinted: prettyPrinted), as: UTF8.self)
    }

}
