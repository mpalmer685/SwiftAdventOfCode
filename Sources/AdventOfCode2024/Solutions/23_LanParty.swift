import AOCKit

struct LanParty: Puzzle {
    static let day = 23

    private typealias Graph = [String: Set<String>]

    func part1(input: Input) throws -> Int {
        let graph = graph(from: input)

        return findTripleCliques(in: graph).count { network in
            network.contains { $0.hasPrefix("t") }
        }
    }

    func part2(input: Input) throws -> String {
        let graph = graph(from: input)
        let biggestClique = findBiggestClique(in: graph)
        return biggestClique.sorted().joined(separator: ",")
    }

    private func graph(from input: Input) -> Graph {
        input.lines.reduce(into: [:]) { connections, line in
            let computers = line.words(separatedBy: "-").map(\.raw)
            assert(computers.count == 2)
            let (left, right) = (computers[0], computers[1])
            connections[left, default: []].insert(right)
            connections[right, default: []].insert(left)
        }
    }

    private func findTripleCliques(in graph: Graph) -> Set<Set<String>> {
        var cliques = Set<Set<String>>()

        for (computer, neighbors) in graph {
            for (neighbor1, neighbor2) in neighbors.pairs()
                where graph[neighbor1]!.contains(neighbor2)
            {
                cliques.insert([computer, neighbor1, neighbor2])
            }
        }

        return cliques
    }

    private func findBiggestClique(in graph: Graph) -> Set<String> {
        // Bron-Kerbosch algorithm
        func findMaximalClique(
            current: Set<String>,
            candidates: Set<String>,
            visited: Set<String>,
            maxClique: inout Set<String>
        ) {
            if candidates.isEmpty, visited.isEmpty {
                if current.count > maxClique.count {
                    maxClique = current
                }
                return
            }

            var candidates = candidates, visited = visited
            for computer in candidates {
                let neighbors = graph[computer]!
                findMaximalClique(
                    current: current.union([computer]),
                    candidates: candidates.intersection(neighbors),
                    visited: visited.intersection(neighbors),
                    maxClique: &maxClique
                )
                candidates.remove(computer)
                visited.insert(computer)
            }
        }

        let allNodes = Set(graph.keys)
        var maxClique = Set<String>()
        findMaximalClique(current: [], candidates: allNodes, visited: [], maxClique: &maxClique)

        return maxClique
    }
}

private extension Collection {
    func pairs() -> [(Element, Element)] {
        combinations(ofCount: 2).map { ($0[0], $0[1]) }
    }
}

extension LanParty: TestablePuzzle {
    var testCases: [TestCase<Int, String>] {
        [
            .init(input: .example, part1: 7, part2: "co,de,ka,ta"),
        ]
    }
}
