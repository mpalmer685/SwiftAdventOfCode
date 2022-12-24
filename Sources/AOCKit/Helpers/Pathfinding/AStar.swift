public protocol AStarPathfindingGraph: PathfindingGraph {
    associatedtype Cost: Numeric & Comparable

    func costToMove(from: State, to: State) -> Cost

    func distance(from: State, to: State) -> Cost
}

public final class AStarPathfinder<Map: AStarPathfindingGraph>: Pathfinding {
    public typealias Graph = Map
    public typealias GraphState = Map.State
    public typealias Cost = Map.Cost

    private final class PathNode: Comparable {
        let state: GraphState
        let parent: PathNode?

        var fScore: Cost { gScore + hScore }
        var gScore: Cost
        var hScore: Cost

        init(_ state: GraphState, parent: PathNode? = nil, moveCost: Cost = 0, hScore: Cost = 0) {
            self.state = state
            self.parent = parent
            gScore = (parent?.gScore ?? 0) + moveCost
            self.hScore = hScore
        }

        static func == (lhs: PathNode, rhs: PathNode) -> Bool {
            lhs.state == rhs.state
        }

        static func < (lhs: PathNode, rhs: PathNode) -> Bool {
            lhs.fScore < rhs.fScore
        }
    }

    private let map: Map

    public init(_ map: Map) {
        self.map = map
    }

    public func path(from start: GraphState, to end: GraphState) -> [GraphState] {
        var frontier = Heap<PathNode>.minHeap()
        frontier.insert(PathNode(start))

        var explored = [GraphState: Cost]()
        explored[start] = 0

        while let currentNode = frontier.remove() {
            let currentState = currentNode.state

            if map.state(currentState, matchesGoal: end) {
                var result = [GraphState]()
                var node: PathNode? = currentNode
                while let n = node {
                    result.append(n.state)
                    node = n.parent
                }
                return Array(result.reversed().dropFirst())
            }

            for nextState in map.nextStates(from: currentState) {
                let moveCost = map.costToMove(from: currentState, to: nextState)
                let newCost = currentNode.gScore + moveCost

                if explored[nextState] == nil || explored[nextState]! > newCost {
                    explored[nextState] = newCost
                    let hScore = map.distance(from: currentState, to: nextState)
                    let node = PathNode(
                        nextState,
                        parent: currentNode,
                        moveCost: moveCost,
                        hScore: hScore
                    )
                    frontier.insert(node)
                }
            }
        }

        return []
    }
}
