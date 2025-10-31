public protocol Graph {
    associatedtype Node: Hashable

    func neighbors(of node: Node) -> [Node]
}

public extension Graph {
    @discardableResult
    func depthFirstTraverse(
        from start: Node,
        visitor: (Node) -> Void = { _ in },
        until goalReached: (Node) -> Bool = { _ in false },
    ) -> [Node] {
        var frontier = Stack<Path<Node>>()
        frontier.push(Path(start))

        var explored = Set<Node>()
        explored.insert(start)

        while let current = frontier.pop() {
            let node = current.value
            visitor(node)

            if goalReached(node) {
                return current.path
            }

            for next in neighbors(of: node) where !explored.contains(next) {
                frontier.push(Path(next, parent: current))
                explored.insert(next)
            }
        }

        return []
    }

    @discardableResult
    private func breadthFirstTraverse(
        from start: Node,
        visitor: (Path<Node>) -> Void,
        until goalReached: (Node) -> Bool,
    ) -> [Node] {
        var frontier = Queue<Path<Node>>()
        frontier.push(Path(start))

        var explored = Set<Node>()
        explored.insert(start)

        while let current = frontier.pop() {
            visitor(current)
            let node = current.value

            if goalReached(node) {
                return current.path
            }

            for next in neighbors(of: node) where !explored.contains(next) {
                frontier.push(Path(next, parent: current))
                explored.insert(next)
            }
        }

        return []
    }

    @discardableResult
    func breadthFirstTraverse(
        from start: Node,
        visitor: (Node) -> Void = { _ in },
        until goalReached: (Node) -> Bool = { _ in false },
    ) -> [Node] {
        breadthFirstTraverse(from: start, visitor: { visitor($0.value) }, until: goalReached)
    }

    func shortestPath(from start: Node, until goalReached: (Node) -> Bool) -> [Node] {
        breadthFirstTraverse(from: start, until: goalReached)
    }

    func shortestPath(from start: Node, to end: Node) -> [Node] {
        breadthFirstTraverse(from: start, until: { $0 == end })
    }

    func nodesAccessible(from start: Node) -> [Node: Int] {
        var nodesAccessible: [Node: Int] = [:]
        breadthFirstTraverse(
            from: start,
            visitor: { p in nodesAccessible[p.value] = p.path.count },
            until: { _ in false },
        )
        return nodesAccessible
    }

    func furthestNode(from start: Node) -> (node: Node, distance: Int) {
        var pair = (start, 0)
        breadthFirstTraverse(
            from: start,
            visitor: { p in pair = (p.value, p.path.count) },
            until: { _ in false },
        )
        return pair
    }
}

private final class Path<Value: Hashable>: LinkedPath {
    let value: Value
    let parent: Path<Value>?

    init(_ value: Value, parent: Path<Value>? = nil) {
        self.value = value
        self.parent = parent
    }
}
