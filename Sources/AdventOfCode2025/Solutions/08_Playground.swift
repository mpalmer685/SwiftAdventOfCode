import AOCKit

struct Playground: Puzzle {
    static let day = 8

    func part1(input: Input) async throws -> Int {
        try await part1(input: input, 1000)
    }

    func part1(input: Input, _ connectionsToMake: Int) async throws -> Int {
        let (boxes, pairs) = parseBoxes(from: input)

        var circuits = DisjointSet(boxes)
        for (first, second) in pairs.prefix(connectionsToMake) {
            circuits.unionSets(containing: first, and: second)
        }

        return circuits.allSets()
            .sorted(using: \.count)
            .suffix(3)
            .product(of: \.count)
    }

    func part2(input: Input) async throws -> Int {
        try await part2(input: input, 0)
    }

    func part2(input: Input, _: Int) async throws -> Int {
        let (boxes, pairs) = parseBoxes(from: input)

        var circuits = DisjointSet(boxes)
        for (first, second) in pairs {
            circuits.unionSets(containing: first, and: second)

            if circuits.setCount() == 1 {
                return first.x * second.x
            }
        }

        fatalError("No solution found")
    }

    private typealias JunctionBoxPair = (first: Point3D, second: Point3D)

    private func parseBoxes(from input: Input) -> ([Point3D], [JunctionBoxPair]) {
        let boxes = input.lines.map { line in
            Point3D(line.csvWords.integers)
        }

        let pairs = boxes
            .combinations(ofCount: 2)
            .map { ($0[0], $0[1]) }
        let pairsToExamine = pairs.count > 20000
            ? pruneByDistance(pairs)
            : pairs

        let distances = pairsToExamine
            .map { first, second in
                (
                    first: first,
                    second: second,
                    distance: first.squaredEuclideanDistance(to: second),
                )
            }
            .sorted(using: \.distance)
            .map { ($0.first, $0.second) }

        return (boxes, distances)
    }

    private func pruneByDistance(_ pairs: [JunctionBoxPair]) -> [JunctionBoxPair] {
        let squaredCutoffDistance = pairs
            .prefix(20000)
            .map { first, second in first.squaredEuclideanDistance(to: second) }
            .sorted()[1000]
        let cutoffDistance = Int(sqrt(Double(squaredCutoffDistance)))

        return pairs.filter { first, second in
            abs(first.x - second.x) <= cutoffDistance &&
                abs(first.y - second.y) <= cutoffDistance &&
                abs(first.z - second.z) <= cutoffDistance
        }
    }
}

private extension Point3D {
    func squaredEuclideanDistance(to other: Self) -> Precision {
        let dx = other.x - x
        let dy = other.y - y
        let dz = other.z - z
        return dx * dx + dy * dy + dz * dz
    }
}

extension Playground: TestablePuzzleWithConfig {
    var testCases: [TestCaseWithConfig<Int, Int, Int>] {
        [
            .given(.example, config: 10).expects(part1: 40, part2: 25272),
        ]
    }
}
