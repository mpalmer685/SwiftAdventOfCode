public protocol DijkstraPathfindingGraph: PathfindingGraph {
    associatedtype Cost: Numeric & Comparable

    func costToMove(from: State, to: State) -> Cost
}

public extension DijkstraPathfindingGraph {
    func costToMove(from: State, to: State) -> Cost {
        1
    }
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
        goalReached: (Graph.State) -> Bool
    ) -> [Graph.State] {
        var frontier = Heap<Node>.minHeap()
        frontier.insert(Node(start))

        var explored = [Graph.State: Graph.Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            if goalReached(currentState) {
                return currentNode.path
            }

            for nextState in graph.nextStates(from: currentState) {
                let node = Node(
                    nextState,
                    parent: currentNode,
                    moveCost: graph.costToMove(from: currentState, to: nextState)
                )

                if let bestCost = explored[nextState], bestCost <= node.costFromStart {
                    continue
                }

                explored[nextState] = node.costFromStart
                frontier.insert(node)
            }
        }

        return []
    }

    public func calculateCosts(from start: Graph.State) -> [Graph.State: Graph.Cost] {
        var frontier = Heap<Node>.minHeap()
        frontier.insert(Node(start))

        var explored = [Graph.State: Graph.Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            for nextState in graph.nextStates(from: currentState) {
                let node = Node(
                    nextState,
                    parent: currentNode,
                    moveCost: graph.costToMove(from: currentState, to: nextState)
                )

                if let bestCost = explored[nextState], bestCost <= node.costFromStart {
                    continue
                }

                explored[nextState] = node.costFromStart
                frontier.insert(node)
            }
        }

        return explored
    }
}
