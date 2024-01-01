import AOCKit

struct Snowverload: Puzzle {
    static let day = 25

    func part1(input: Input) throws -> Int {
        let graph = parse(input)

        let start = furthestNode(from: graph.keys.first!, in: graph)
        let end = furthestNode(from: start, in: graph)

        var traversed = Set<Edge>()
        for _ in 0 ..< 3 {
            let path = traverse(graph, from: start, to: end, avoiding: traversed)
            traversed.formUnion(path.adjacentPairs().map { [$0, $1] })
        }

        let connected = explore(graph, startingAt: start, avoiding: traversed)
        return connected.count * (graph.count - connected.count)
    }

    private func parse(_ input: Input) -> Graph {
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

    private func furthestNode(from start: String, in graph: Graph) -> String {
        var frontier: Queue<String> = [start]
        var explored = Set<String>()

        var result = start

        while let current = frontier.pop() {
            result = current

            for next in graph[current]! where !explored.contains(next) {
                frontier.push(next)
                explored.insert(next)
            }
        }

        return result
    }

    private func traverse(
        _ graph: Graph,
        from start: String,
        to end: String,
        avoiding traversed: Set<Edge>
    ) -> [String] {
        let pathfinder = BreadthFirstSearch(ComponentPathfinder(graph: graph, traversed: traversed))
        return pathfinder.path(from: start, to: end)
    }

    private func explore(
        _ graph: Graph,
        startingAt start: String,
        avoiding traversed: Set<Edge>
    ) -> Set<String> {
        let graph = ComponentPathfinder(graph: graph, traversed: traversed)
        var frontier: Queue<String> = [start]
        var explored: Set<String> = []

        while let current = frontier.pop() {
            for next in graph.nextStates(from: current) where !explored.contains(next) {
                frontier.push(next)
                explored.insert(next)
            }
        }

        return explored
    }
}

private typealias Graph = [String: Set<String>]
private typealias Edge = Set<String>

private struct ComponentPathfinder: PathfindingGraph {
    let graph: Graph
    let traversed: Set<Edge>

    func nextStates(from state: String) -> [String] {
        guard let neighbors = graph[state] else {
            fatalError()
        }
        return neighbors.filter { neighbor in
            !traversed.contains([neighbor, state])
        }
    }
}
