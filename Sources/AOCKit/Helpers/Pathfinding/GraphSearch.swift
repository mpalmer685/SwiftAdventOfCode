public final class BreadthFirstSearch<Map: PathfindingGraph>: Pathfinding {
    private let map: Map

    public init(_ map: Map) {
        self.map = map
    }

    public func path(from start: Map.State, to end: Map.State) -> [Map.State] {
        var frontier = Queue<Node<Map.State>>()
        frontier.push(Node(start))

        var explored = Set<Map.State>()
        explored.insert(start)

        while let currentNode = frontier.pop() {
            let currentState = currentNode.state

            if map.state(currentState, matchesGoal: end) {
                return currentNode.path
            }

            for nextState in map.nextStates(from: currentState)
                where !explored.contains(nextState)
            {
                frontier.push(Node(nextState, parent: currentNode))
                explored.insert(nextState)
            }
        }

        return []
    }
}

public final class DepthFirstSearch<Map: PathfindingGraph>: Pathfinding {
    private let map: Map

    public init(_ map: Map) {
        self.map = map
    }

    public func path(from start: Map.State, to end: Map.State) -> [Map.State] {
        var frontier = Stack<Node<Map.State>>()
        frontier.push(Node(start))

        var explored = Set<Map.State>()
        explored.insert(start)

        while let currentNode = frontier.pop() {
            let currentState = currentNode.state

            if map.state(currentState, matchesGoal: end) {
                return currentNode.path
            }

            for nextState in map.nextStates(from: currentState)
                where !explored.contains(nextState)
            {
                frontier.push(Node(nextState, parent: currentNode))
                explored.insert(nextState)
            }
        }

        return []
    }
}

private final class Node<State: Hashable>: PathNode {
    let state: State
    let parent: Node?

    init(_ state: State, parent: Node? = nil) {
        self.state = state
        self.parent = parent
    }
}
