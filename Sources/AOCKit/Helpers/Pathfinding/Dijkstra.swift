public protocol DijkstraPathfindingGraph: PathfindingGraph {
    associatedtype Cost: Numeric & Comparable

    func costToMove(from: State, to: State) -> Cost
}

public extension DijkstraPathfindingGraph {
    func costToMove(from: State, to: State) -> Cost {
        1
    }
}

public final class DijkstraPathfinder<Map: DijkstraPathfindingGraph>: Pathfinding {
    private final class Node: PathNode, Comparable {
        let state: Map.State
        let parent: Node?

        var costFromStart: Map.Cost

        init(_ state: Map.State, parent: Node? = nil, moveCost: Map.Cost = 0) {
            self.state = state
            self.parent = parent
            costFromStart = (parent?.costFromStart ?? 0) + moveCost
        }

        static func < (lhs: Node, rhs: Node) -> Bool {
            lhs.costFromStart < rhs.costFromStart
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
                    moveCost: map.costToMove(from: currentState, to: nextState)
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

    public func calculateCosts(from start: Map.State) -> [Map.State: Map.Cost] {
        var frontier = Heap<Node>.minHeap()
        frontier.insert(Node(start))

        var explored = [Map.State: Map.Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            for nextState in map.nextStates(from: currentState) {
                let node = Node(
                    nextState,
                    parent: currentNode,
                    moveCost: map.costToMove(from: currentState, to: nextState)
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
