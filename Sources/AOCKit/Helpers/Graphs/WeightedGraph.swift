public protocol WeightedGraph {
    associatedtype Node: Hashable
    associatedtype Cost: Numeric & Comparable = Int

    func neighbors(of node: Node) -> [(Node, Cost)]
}

public extension WeightedGraph {
    private typealias Path = PathNode<Node, Cost>

    @discardableResult
    private func traverse(
        from start: Node,
        until goalReached: (Node) -> Bool
    ) -> (Path?, [Node: Path]) {
        let startSegment = Path(start)

        var frontier = Heap<Path>.minHeap()
        frontier.insert(startSegment)

        var explored: [Node: Path] = [:]
        explored[start] = startSegment

        while let current = frontier.remove() {
            let node = current.value

            if goalReached(node) {
                return (current, explored)
            }

            for (next, cost) in neighbors(of: node) {
                let path = Path(next, moveCost: cost, parent: current)

                if let bestPath = explored[next], bestPath.costFromStart <= path.costFromStart {
                    continue
                }

                explored[next] = path
                frontier.insert(path)
            }
        }

        return (nil, explored)
    }

    func shortestPath(from start: Node, until goalReached: (Node) -> Bool) -> [Node] {
        let (bestPath, _) = traverse(from: start, until: goalReached)
        guard let bestPath else { return [] }
        return bestPath.path
    }

    func shortestPath(from start: Node, to end: Node) -> [Node] {
        shortestPath(from: start, until: { $0 == end })
    }

    func costOfPath(from start: Node, until goalReached: (Node) -> Bool) -> Cost {
        let (bestPath, _) = traverse(from: start, until: goalReached)
        guard let bestPath else { return 0 }
        return bestPath.costFromStart
    }

    func costOfPath(from start: Node, to end: Node) -> Cost {
        costOfPath(from: start, until: { $0 == end })
    }

    func nodesAccessible(from start: Node, until goalReached: (Node) -> Bool = { _ in
        false
    }) -> [Node: Cost] {
        let (_, explored) = traverse(from: start, until: goalReached)
        return explored.mapValues(\.costFromStart)
    }
}

private final class PathNode<Value: Hashable, Cost: Numeric & Comparable>: LinkedPath, Comparable {
    let value: Value
    let costFromStart: Cost
    let parent: PathNode?

    init(_ value: Value) {
        self.value = value
        costFromStart = 0
        parent = nil
    }

    init(_ value: Value, moveCost: Cost, parent: PathNode) {
        self.value = value
        self.parent = parent
        costFromStart = parent.costFromStart + moveCost
    }

    static func < (lhs: PathNode, rhs: PathNode) -> Bool {
        lhs.costFromStart < rhs.costFromStart
    }
}
