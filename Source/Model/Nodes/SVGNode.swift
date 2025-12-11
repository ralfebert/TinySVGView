// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public protocol SVGNode {

    var transform: CGAffineTransform { get set }
    var opacity: Double { get set }
    var id: String? { get set }

    var bounds: CGRect { get }
    var frame: CGRect { get }

}

public extension SVGNode {
    func getNode(byId id: String) -> SVGNode? {
        if self.id == id {
            return self
        }
        if let container = self as? SVGNodeContainer {
            for node in container.contents {
                if let node = node.getNode(byId: id) {
                    return node
                }
            }
        }
        return .none
    }
}
