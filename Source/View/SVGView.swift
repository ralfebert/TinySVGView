// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreText
import SwiftUI

public struct SVGView: View {

    public let node: SVGNode?

    public init(contentsOf url: URL) {
        self.node = SVGParser.parse(contentsOf: url)
    }

    public init(svg: SVGNode) {
        self.node = svg
    }

    public var body: some View {
        if let node {
            Canvas(rendersAsynchronously: true) { ctx, size in
                ctx.withCGContext { ctx in
                    node.draw(ctx: ctx, size: size)
                }
            }
        }
    }

}

public extension SVGNode {

    func draw(ctx: CGContext, size: CGSize) {

        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }

        if let node = self as? SVGViewport {
            ctx.concatenate(node.preserveAspectRatio.layout(size: node.size, into: size))
        }
        ctx.concatenate(self.transform)

        ctx.setAlpha(self.opacity)

        switch self {
        case let node as SVGViewport:
            node.drawContents(ctx: ctx, size: size)
        case let node as SVGGroup:
            node.drawContents(ctx: ctx, size: size)
        case let node as SVGPath:
            ctx.draw(path: node.toBezierPath().cgPath, shape: node, fillRule: node.fillRule)
        case let node as SVGRect:
            ctx.draw(path: node.toPath(), shape: node)
        case let node as SVGCircle:
            ctx.draw(path: node.toPath(), shape: node)
        case let node as SVGEllipse:
            ctx.draw(path: node.toPath(), shape: node)
        case let node as SVGLine:
            ctx.draw(path: node.toPath(), shape: node)
        case let node as SVGPolyline:
            ctx.draw(path: node.toPath(), shape: node, fillRule: node.fillRule)
        case let node as SVGPolygon:
            ctx.draw(path: node.toPath(), shape: node, fillRule: node.fillRule)
        case let node as SVGText:
            ctx.draw(text: node)
        default:
            fatalError("Unknown SVGNode type: \(self)")
        }

    }

}

private extension CGContext {

    func draw(path: CGPath, shape: some SVGShape, fillRule: CGPathFillRule = .winding) {

        // An outside-aligned stroke is drawn first and the fill painted on top of it.
        if shape.stroke?.alignment != .outside, case let .color(color) = shape.fill {
            setFillColor(color.cgColor)
            addPath(path)
            fillPath(using: fillRule)
        }

        if let stroke = shape.stroke {

            if case let .color(color) = stroke.fill {
                setFillColor(color.cgColor)
            }

            switch stroke.alignment {
            case .center:
                setLineWidth(stroke.width)
            case .inside:
                // Twice the width, with the outer half clipped away.
                setLineWidth(stroke.width * 2)
                addPath(path)
                clip()
            case .outside:
                // Twice the width; the inner half is covered by the fill drawn on top below.
                setLineWidth(stroke.width * 2)
            }

            setLineCap(stroke.cap)
            setLineJoin(stroke.join)
            setMiterLimit(stroke.miterLimit)
            if !stroke.dashes.isEmpty {
                setLineDash(phase: stroke.offset, lengths: stroke.dashes)
            }

            addPath(path)
            // Applies scaleFactor in transform to the line width
            replacePathWithStrokedPath()
            fillPath()

            if stroke.alignment == .outside, case let .color(color) = shape.fill {
                setFillColor(color.cgColor)
                addPath(path)
                fillPath(using: fillRule)
            }

        }
    }

    func draw(text: SVGText) {
        guard !text.text.isEmpty else {
            return
        }
        let line = text.makeLine()

        saveGState()
        defer {
            restoreGState()
        }
        // CTLineDraw expects a y-up coordinate system; flip around the baseline so the
        // glyphs come out upright in the y-down system SVG (and Canvas) use.
        textMatrix = .identity
        translateBy(x: text.x + text.anchorOffset(of: line), y: text.y)
        scaleBy(x: 1, y: -1)

        if let stroke = text.stroke, case let .color(color) = stroke.fill {
            setStrokeColor(color.cgColor)
            setLineWidth(stroke.width)
            setTextDrawingMode(text.fillColor == nil ? .stroke : .fillStroke)
        }
        CTLineDraw(line, self)
    }

}

private extension SVGNodeContainer {

    func drawContents(ctx: CGContext, size: CGSize) {
        for node in self.contents {
            node.draw(ctx: ctx, size: size)
        }
    }

}

public extension SVGColor {

    func toSwiftUI() -> Color {
        Color(red: Double(r) / 0xFF, green: Double(g) / 0xFF, blue: Double(b) / 0xFF).opacity(opacity)
    }

}
