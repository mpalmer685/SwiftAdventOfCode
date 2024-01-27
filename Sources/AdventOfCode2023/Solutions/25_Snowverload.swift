import AOCKit

struct Snowverload: Puzzle {
    static let day = 25

    func part1(input: Input) throws -> Int {
        let graph = parse(input)

        var pathfinder = ComponentPathfinder(graph: graph)
        let start = pathfinder.furthestNode(from: graph.keys.first!).node
        let end = pathfinder.furthestNode(from: start).node

        for _ in 0 ..< 3 {
            let path = pathfinder.shortestPath(from: start, to: end)
            pathfinder = pathfinder.visiting(path)
        }

        let connected = pathfinder.nodesAccessible(from: start)
        return connected.count * (graph.count - connected.count)
    }

    private func parse(_ input: Input) -> ComponentGraph {
        input.lines.reduce(into: [:]) { nodes, line in
            let parts = line.words(separatedBy: ": ")
            let start = parts[0].raw
            let ends = parts[1].words(separatedBy: .whitespaces).map(\.raw)
            for end in ends {
                nodes[start, default: []].insert(end)
                nodes[end, default: []].insert(start)
            }
        }
    }
}

private typealias ComponentGraph = [String: Set<String>]
private typealias Edge = Set<String>

private struct ComponentPathfinder: Graph {
    let graph: ComponentGraph
    let traversed: Set<Edge>

    init(graph: ComponentGraph, traversed: Set<Edge> = []) {
        self.graph = graph
        self.traversed = traversed
    }

    func neighbors(of state: String) -> [String] {
        guard let neighbors = graph[state] else {
            fatalError()
        }
        return neighbors.filter { neighbor in
            !traversed.contains([neighbor, state])
        }
    }

    func visiting(_ path: [String]) -> Self {
        Self(
            graph: graph,
            traversed: traversed.union(path.adjacentPairs().map { [$0, $1] })
        )
    }
}
