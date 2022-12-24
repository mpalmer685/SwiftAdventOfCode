public protocol PathfindingGraph {
    associatedtype State: Hashable

    func nextStates(from state: State) -> [State]

    func state(_ state: State, matchesGoal goal: State) -> Bool
}

public extension PathfindingGraph {
    func state(_ state: State, matchesGoal goal: State) -> Bool {
        state == goal
    }
}

public protocol Pathfinding {
    associatedtype Graph: PathfindingGraph

    func path(from start: Graph.State, to end: Graph.State) -> [Graph.State]
}
