public final class BreadthFirstSearch<Graph: PathfindingGraph> {
    private let graph: Graph

    public init(_ graph: Graph) {
        self.graph = graph
    }

    public func path(from start: Graph.State, to end: Graph.State) -> [Graph.State] {
        path(from: start) { $0 == end }
    }

    public func path(from start: Graph.State, goalReached: (Graph.State) -> Bool) -> [Graph.State] {
        var frontier = Queue<Node<Graph.State>>()
        frontier.push(Node(start))

        var explored = Set<Graph.State>()
        explored.insert(start)

        while let currentNode = frontier.pop() {
            let currentState = currentNode.state

            if goalReached(currentState) {
                return currentNode.path
            }

            for nextState in graph.nextStates(from: currentState)
                where !explored.contains(nextState)
            {
                frontier.push(Node(nextState, parent: currentNode))
                explored.insert(nextState)
            }
        }

        return []
    }
}

public final class DepthFirstSearch<Graph: PathfindingGraph> {
    public let graph: Graph

    public init(_ graph: Graph) {
        self.graph = graph
    }

    public func path(from start: Graph.State, to end: Graph.State) -> [Graph.State] {
        path(from: start) { $0 == end }
    }

    public func path(from start: Graph.State, goalReached: (Graph.State) -> Bool) -> [Graph.State] {
        var frontier = Stack<Node<Graph.State>>()
        frontier.push(Node(start))

        var explored = Set<Graph.State>()
        explored.insert(start)

        while let currentNode = frontier.pop() {
            let currentState = currentNode.state

            if goalReached(currentState) {
                return currentNode.path
            }

            for nextState in graph.nextStates(from: currentState)
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
