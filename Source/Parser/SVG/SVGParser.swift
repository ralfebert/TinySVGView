// MIT license
// Derived from https://github.com/exyte/SVGView

import Foundation

final class XMLDelegate: NSObject, XMLParserDelegate {

    let logger: SVGLogger
    var root: SVGNode?
    var stack = [SVGNode]()

    init(logger: SVGLogger) {
        self.logger = logger
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes: [String: String] = [:]) {
        precondition(root == nil)

        var node: SVGNode
        switch elementName {
        case "svg":
            let w = SVGHelper.parseDouble(attributes, "width")
            let h = SVGHelper.parseDouble(attributes, "height")
            let par = SVGPreserveAspectRatio.parsePreserveAspectRatio(string: attributes["preserveAspectRatio"])
            node = SVGViewport(width: w, height: h, preserveAspectRatio: par)

        case "g":
            node = SVGGroup(contents: [])

        case "path":
            let segments = PathReader(input: attributes["d"] ?? "").read()
            var path = SVGPath(segments: segments, fillRule: attributes["fill-rule"] == "evenodd" ? .evenOdd : .winding)
            path.fill = SVGHelper.parseFill(attributes)
            path.stroke = SVGHelper.parseStroke(attributes)
            node = path

        default:
            fatalError("Unknown element: \(elementName)")
        }

        Self.parseBasicAttributes(properties: attributes, node: &node)

        stack.append(node)
    }

    static func parseBasicAttributes(properties: [String: String], node: inout SVGNode) {
        let transform = SVGHelper.parseTransform(properties["transform"] ?? "")
        node.transform = node.transform.concatenating(transform)
        node.opacity = SVGHelper.parseOpacity(properties, "opacity")
        node.id = properties["id"]
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let node = stack.popLast()!
        if stack.isEmpty {
            precondition(elementName == "svg")
            precondition(root == nil)
            root = node
        } else {
            var parent = stack.last as! SVGNodeContainer
            parent.contents.append(node)
            stack[stack.count - 1] = parent
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        logger.log(error: parseError)
    }

}

public enum SVGParser {

    public static func parse(contentsOf url: URL, settings: SVGSettings = .default) -> SVGNode? {
        parse(XMLParser(contentsOf: url), logger: settings.logger)
    }

    public static func parse(data: Data, settings: SVGSettings = .default) -> SVGNode? {
        parse(XMLParser(data: data), logger: settings.logger)
    }

    public static func parse(stream: InputStream, settings: SVGSettings = .default) -> SVGNode? {
        parse(XMLParser(stream: stream), logger: settings.logger)
    }

    private static func parse(_ parser: XMLParser?, logger: SVGLogger) -> SVGNode? {
        let delegate = XMLDelegate(logger: logger)
        parser?.delegate = delegate
        parser?.parse()
        return delegate.root
    }

}
