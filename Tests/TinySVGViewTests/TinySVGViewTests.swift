// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import SnapshotTesting
import Testing
@testable import TinySVGView
import WebColor

private func parse(_ name: String) throws -> SVGViewport {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "svg"))
    return try #require(SVGParser.parse(contentsOf: url) as? SVGViewport)
}

/// One document that exercises every element and attribute TinySVGView supports.
private func sampleSVG() throws -> SVGViewport {
    try parse("sample")
}

@Test func rendersSupportedFeatures() throws {
    let svg = try sampleSVG()
    assertSnapshot(of: image(of: svg), as: .image(precision: 0.99, perceptualPrecision: 0.98), named: platform)
}

/// The document comes back out as it went in, apart from what TinySVGView doesn't keep: unsupported
/// elements, the attribute order and the spacing within `d` and `transform`.
@Test func writesSupportedFeatures() throws {
    try assertSnapshot(of: sampleSVG().xmlString(), as: .svg, named: "sample")
}

/// What is written out has to parse back into the same drawing.
@Test func roundTripsThroughXML() throws {
    let svg = try sampleSVG()
    let rewritten = try #require(try SVGParser.parse(string: svg.xmlString()) as? SVGViewport)
    #expect(pngData(of: rewritten) == pngData(of: svg))
}

/// The basic shapes, drawn from the sample of the MDN "Basic shapes" page.
@Test func rendersBasicShapes() throws {
    let svg = try parse("shapes")
    assertSnapshot(of: image(of: svg), as: .image(precision: 0.99, perceptualPrecision: 0.98), named: platform)
}

@Test func writesBasicShapes() throws {
    try assertSnapshot(of: parse("shapes").xmlString(), as: .svg, named: "shapes")
}

/// `<use>` draws the referenced `<defs>` content at the use's transform; the defs themselves stay
/// invisible. The reference is looked up while drawing and survives the write/parse round trip.
@Test func rendersUseReferencingDefs() throws {
    let document = """
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="60" height="30">
       <defs>
          <g id="dot"><circle cx="0" cy="0" r="5" fill="black" /></g>
       </defs>
       <use xlink:href="#dot" transform="translate(10,15)" />
       <use xlink:href="#dot" transform="translate(40,15) scale(2,2)" />
    </svg>
    """
    let svg = try #require(SVGParser.parse(string: document) as? SVGViewport)

    let uses = svg.contents.compactMap { $0 as? SVGUse }
    #expect(uses.count == 2)
    #expect(uses.map(\.href) == ["dot", "dot"])

    let smallDot = SVGCircle(cx: 10, cy: 15, r: 5, fill: .color(WrittenWebColor(.black)))
    let bigDot = SVGCircle(cx: 40, cy: 15, r: 10, fill: .color(WrittenWebColor(.black)))
    let reference = SVGViewport(width: 60, height: 30, contents: [smallDot, bigDot])
    #expect(pngData(of: svg) == pngData(of: reference))

    let rewritten = try #require(try SVGParser.parse(string: svg.xmlString()) as? SVGViewport)
    #expect(pngData(of: rewritten) == pngData(of: svg))
}

@Test func picksTheFaceForWeightAndStyle() {
    #expect(fullName(of: SVGFont(family: "Helvetica")) == "Helvetica")
    #expect(fullName(of: SVGFont(family: "Helvetica", weight: .bold)) == "Helvetica Bold")
    #expect(fullName(of: SVGFont(family: "Helvetica", weight: .number(600))) == "Helvetica Bold")
    #expect(fullName(of: SVGFont(family: "Helvetica", weight: .number(300))) == "Helvetica")
    #expect(fullName(of: SVGFont(family: "Helvetica", style: .italic)) == "Helvetica Oblique")
}

private func fullName(of font: SVGFont) -> String {
    CTFontCopyFullName(font.ctFont) as String
}

@Test func skipsUnsupportedElements() throws {
    let svg = try sampleSVG()
    #expect(svg.contents.count == 6)
    #expect((svg.contents[1] as? SVGGroup)?.contents.count == 3)
}

private extension Snapshotting where Value == String, Format == String {

    /// Like `.lines`, but the reference file can be opened as the SVG it is.
    static var svg: Snapshotting {
        var strategy = Snapshotting.lines
        strategy.pathExtension = "svg"
        return strategy
    }

}

// MARK: - Rendering

private let scale: CGFloat = 2

private func cgImage(of node: SVGNode, size: CGSize) -> CGImage {
    let context = CGContext(
        data: nil,
        width: Int(size.width * scale),
        height: Int(size.height * scale),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.setFillColor(gray: 1, alpha: 1)
    context.fill(CGRect(origin: .zero, size: CGSize(width: size.width * scale, height: size.height * scale)))
    // CGContext draws bottom-up, SVG is top-down.
    context.translateBy(x: 0, y: size.height * scale)
    context.scaleBy(x: scale, y: -scale)
    node.draw(ctx: context, size: size)
    return context.makeImage()!
}

private func pngData(of svg: SVGViewport) -> Data {
    let image = cgImage(of: svg, size: svg.size)
    let data = NSMutableData()
    let destination = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
    return data as Data
}

#if canImport(UIKit)
    import UIKit

    private let platform = "ios"

    private func image(of svg: SVGViewport) -> UIImage {
        UIImage(cgImage: cgImage(of: svg, size: svg.size), scale: scale, orientation: .up)
    }

#elseif canImport(AppKit)
    import AppKit

    private let platform = "macos"

    private func image(of svg: SVGViewport) -> NSImage {
        NSImage(cgImage: cgImage(of: svg, size: svg.size), size: svg.size)
    }
#endif
