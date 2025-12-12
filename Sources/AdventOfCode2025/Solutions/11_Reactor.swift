import AOCKit

struct Reactor: Puzzle {
    static let day = 11

    func part1(input: Input) async throws -> Int {
        let connections = parseConnections(from: input)

        let graph = ConnectionMap(connections: connections)
        return graph.countPaths(from: "you", to: "out")
    }

    func part2(input: Input) async throws -> Int {
        let connections = parseConnections(from: input)

        let pathfinder = ConnectionMap(connections: connections, endpoints: ["out"])
        let (firstStop, secondStop) = pathfinder.shortestPath(from: "dac", to: "fft").isEmpty
            ? ("fft", "dac")
            : ("dac", "fft")

        let paths: [(String, String, Set<String>)] = [
            ("svr", firstStop, [secondStop, "out"]),
            (firstStop, secondStop, ["out"]),
            (secondStop, "out", []),
        ]

        return paths.product { start, top, endpoints in
            countPaths(from: start, to: top, in: connections, alsoStoppingAt: endpoints)
        }
    }

    private func countPaths(
        from start: String,
        to end: String,
        in connections: [String: Set<String>],
        alsoStoppingAt endpoints: Set<String> = [],
    ) -> Int {
        let graph = ConnectionMap(connections: connections, endpoints: endpoints)
        return graph.countPaths(from: start, to: end)
    }

    private func parseConnections(from input: Input) -> [String: Set<String>] {
        var connections = [String: Set<String>]()
        for line in input.lines {
            let parts = line.words(separatedBy: ": ")
            let from = parts[0].raw
            let tos = parts[1].words(separatedBy: .whitespaces).map(\.raw)
            connections[from] = Set(tos)
        }
        return connections
    }
}

private struct ConnectionMap: Graph {
    private let connections: [String: Set<String>]
    private let endpoints: Set<String>

    init(connections: [String: Set<String>], endpoints: Set<String> = []) {
        self.connections = connections
        self.endpoints = endpoints
    }

    func neighbors(of node: String) -> [String] {
        guard let connected = connections[node] else {
            fatalError("No connections for \(node)")
        }
        return connected.reject { endpoints.contains($0) }
    }
}

extension Reactor: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.file("example1")).expects(part1: 5),
            .given(.file("example2")).expects(part2: 2),
        ]
    }
}
