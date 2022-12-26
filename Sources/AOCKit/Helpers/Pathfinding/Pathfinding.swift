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
    associatedtype State

    func path(from start: State, to end: State) -> [State]
}

protocol PathNode: Hashable {
    associatedtype State: Hashable

    var state: State { get }
    var parent: Self? { get }
}

extension PathNode {
    var path: [State] {
        var result = [State]()
        var node = self
        while let parent = node.parent {
            result.append(node.state)
            node = parent
        }
        return result.reversed()
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
}
