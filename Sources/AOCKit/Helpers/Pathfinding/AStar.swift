public protocol AStarPathfindingGraph: PathfindingGraph {
    associatedtype Cost: Numeric & Comparable

    func costToMove(from: State, to: State) -> Cost

    func estimatedCost(from: State, to: State) -> Cost
}

public final class AStarPathfinder<Map: AStarPathfindingGraph>: Pathfinding {
    private final class Node: PathNode, Comparable {
        let state: Map.State
        let parent: Node?

        var estimatedTotalCost: Map.Cost { costFromStart + estimatedCostToDestination }
        var costFromStart: Map.Cost
        var estimatedCostToDestination: Map.Cost

        init(
            _ state: Map.State,
            parent: Node? = nil,
            moveCost: Map.Cost = 0,
            estimatedCostToDestination: Map.Cost = 0
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

    private let map: Map

    public init(_ map: Map) {
        self.map = map
    }

    public func path(from start: Map.State, to end: Map.State) -> [Map.State] {
        var frontier = Heap<Node>.minHeap()
        frontier.insert(Node(start))

        var explored = [Map.State: Map.Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            if map.state(currentState, matchesGoal: end) {
                return currentNode.path
            }

            for nextState in map.nextStates(from: currentState) {
                let node = Node(
                    nextState,
                    parent: currentNode,
                    moveCost: map.costToMove(from: currentState, to: nextState),
                    estimatedCostToDestination: map.estimatedCost(from: nextState, to: end)
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