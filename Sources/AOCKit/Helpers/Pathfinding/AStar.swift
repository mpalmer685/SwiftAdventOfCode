public protocol AStarPathfindingGraph: PathfindingGraph {
    associatedtype Cost: Numeric & Comparable

    func costToMove(from: State, to: State) -> Cost

    func estimatedCost(from: State, to: State) -> Cost
}

public final class AStarPathfinder<Graph: AStarPathfindingGraph> {
    private final class Node: PathNode, Comparable {
        let state: Graph.State
        let parent: Node?

        var estimatedTotalCost: Graph.Cost { costFromStart + estimatedCostToDestination }
        var costFromStart: Graph.Cost
        var estimatedCostToDestination: Graph.Cost

        init(
            _ state: Graph.State,
            parent: Node? = nil,
            moveCost: Graph.Cost = 0,
            estimatedCostToDestination: Graph.Cost = 0
        ) {
            self.state = state
            self.parent = parent
            costFromStart = (parent?.costFromStart ?? 0) + moveCost
            self.estimatedCostToDestination = estimatedCostToDestination
        }

        static func < (lhs: Node, rhs: Node) -> Bool {
            lhs.estimatedTotalCost < rhs.estimatedTotalCost
        }
    }

    private let graph: Graph

    public init(_ graph: Graph) {
        self.graph = graph
    }

    public func path(
        from start: Graph.State,
        to end: Graph.State,
        goalReached: ((Graph.State) -> Bool)? = nil
    ) -> [Graph.State] {
        let goalReached = goalReached ?? stateEquals(end)

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
                    moveCost: graph.costToMove(from: currentState, to: nextState),
                    estimatedCostToDestination: graph.estimatedCost(from: nextState, to: end)
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
}

private func stateEquals<State: Equatable>(_ goal: State) -> (State) -> Bool {
    { $0 == goal }
}
