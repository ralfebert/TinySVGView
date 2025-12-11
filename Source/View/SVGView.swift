// MIT license
// Derived from https://github.com/exyte/SVGView

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
            let path = node.toBezierPath().cgPath


            switch node.fill {
            case let .color(color):
                ctx.setFillColor(color.toSwiftUI().cgColor!)
                ctx.addPath(path)
                ctx.fillPath(using: node.fillRule)

            case .none:
                break
            }

            if let stroke = node.stroke {

                if case let .color(color) = stroke.fill {
                    ctx.setFillColor(color.toSwiftUI().cgColor!)
                }

                ctx.setLineWidth(stroke.width)

                ctx.setLineCap(stroke.cap)
                ctx.setLineJoin(stroke.join)
                ctx.setMiterLimit(stroke.miterLimit)
                if !stroke.dashes.isEmpty {
                    ctx.setLineDash(phase: stroke.offset, lengths: stroke.dashes)
                }

                ctx.addPath(path)
                // Applies scaleFactor in transform to the line width
                ctx.replacePathWithStrokedPath()
                ctx.fillPath()

            }
        default:
            fatalError("Unknown SVGNode type: \(self)")
        }

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
