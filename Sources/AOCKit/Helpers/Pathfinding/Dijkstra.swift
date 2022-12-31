public protocol DijkstraPathfindingGraph {
    associatedtype State: Equatable & Hashable
    associatedtype Cost: Numeric & Comparable

    func nextStates(from state: State) -> [(State, Cost)]
}

public final class DijkstraPathfinder<Graph: DijkstraPathfindingGraph> {
    private final class Node: PathNode, Comparable {
        let state: Graph.State
        let parent: Node?

        var costFromStart: Graph.Cost

        init(_ state: Graph.State, parent: Node? = nil, moveCost: Graph.Cost = 0) {
            self.state = state
            self.parent = parent
            costFromStart = (parent?.costFromStart ?? 0) + moveCost
        }

        static func < (lhs: Node, rhs: Node) -> Bool {
            lhs.costFromStart < rhs.costFromStart
        }
    }

    private let graph: Graph

    public init(_ graph: Graph) {
        self.graph = graph
    }

    public func path(from start: Graph.State, to end: Graph.State) -> [Graph.State] {
        path(from: start) { $0 == end }
    }

    public func path(
        from start: Graph.State,
        until goalReached: (Graph.State) -> Bool
    ) -> [Graph.State] {
        let (finalNode, _) = explorePaths(from: start, until: goalReached)
        guard let finalNode else { return [] }
        return finalNode.path
    }

    public func costOfPath(from start: Graph.State, to end: Graph.State) -> Graph.Cost {
        costOfPath(from: start) { $0 == end }
    }

    public func costOfPath(
        from start: Graph.State,
        until goalReached: (Graph.State) -> Bool
    ) -> Graph.Cost {
        let (finalNode, _) = explorePaths(from: start, until: goalReached)
        guard let finalNode else { return 0 }
        return finalNode.costFromStart
    }

    public func calculateCosts(from start: Graph.State) -> [Graph.State: Graph.Cost] {
        let (_, costs) = explorePaths(from: start)
        return costs
    }

    private func explorePaths(
        from start: Graph.State,
        until goalReached: (Graph.State) -> Bool = never
    ) -> (Node?, [Graph.State: Graph.Cost]) {
        var frontier = Heap<Node>.minHeap()
        frontier.insert(Node(start))

        var explored = [Graph.State: Graph.Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            if goalReached(currentState) {
                return (currentNode, explored)
            }

            for (nextState, cost) in graph.nextStates(from: currentState) {
                let node = Node(
                    nextState,
                    parent: currentNode,
                    moveCost: cost
                )

                if let bestCost = explored[nextState], bestCost <= node.costFromStart {
                    continue
                }

                explored[nextState] = node.costFromStart
                frontier.insert(node)
            }
        }

        return (nil, explored)
    }
}

private func never<T>(_: T) -> Bool { false }
