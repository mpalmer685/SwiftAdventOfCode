public protocol PathfindingGraph {
    associatedtype State: Equatable & Hashable

    func nextStates(from state: State) -> [State]
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
