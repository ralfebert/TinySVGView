// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

public protocol SVGNode {

    var id: String? { get set }
    var transform: CGAffineTransform { get set }
    var opacity: Double { get set }

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

    /// Every node in the tree that carries an id, keyed by it; the first one wins on duplicates.
    func nodesById() -> [String: SVGNode] {
        var ids = [String: SVGNode]()
        collectNodesById(into: &ids)
        return ids
    }
}

private extension SVGNode {
    func collectNodesById(into ids: inout [String: SVGNode]) {
        if let id, ids[id] == nil {
            ids[id] = self
        }
        if let container = self as? SVGNodeContainer {
            for node in container.contents {
                node.collectNodesById(into: &ids)
            }
        }
    }
}
