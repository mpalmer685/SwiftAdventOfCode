import AOCKit

struct Playground: Puzzle {
    static let day = 8

    func part1(input: Input) async throws -> Int {
        try await part1(input: input, 1000)
    }

    func part1(input: Input, _ connectionsToMake: Int) async throws -> Int {
        let (_, pairs) = parseBoxes(from: input)

        var circuits = CircuitSet()
        for (first, second, _) in pairs.prefix(connectionsToMake) {
            circuits.unite(first, second)
        }

        return circuits.allSets
            .sorted(using: \.count)
            .suffix(3)
            .product(of: \.count)
    }

    func part2(input: Input) async throws -> Int {
        try await part2(input: input, 0)
    }

    func part2(input: Input, _: Int) async throws -> Int {
        let (boxes, pairs) = parseBoxes(from: input)

        var circuits = CircuitSet()
        for (first, second, _) in pairs {
            circuits.unite(first, second)

            if circuits.count == boxes.count {
                return first.x * second.x
            }
        }

        fatalError("No solution found")
    }

    private typealias JunctionBoxPair = (first: Point3D, second: Point3D, distance: Int)

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

        return (boxes, distances)
    }

    private func pruneByDistance(_ pairs: [(Point3D, Point3D)]) -> [(Point3D, Point3D)] {
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

private struct CircuitSet {
    var parents: [Point3D: Point3D] = [:]

    var count: Int { parents.count }
    var setCount: Int { Set(parents.values).count }

    mutating func unite(_ first: Point3D, _ second: Point3D) {
        let firstRoot = find(first)
        let secondRoot = find(second)

        guard firstRoot != secondRoot else {
            return
        }

        // keep the tree shallow by randomly selecting a new root
        if Bool.random() {
            parents[secondRoot] = firstRoot
        } else {
            parents[firstRoot] = secondRoot
        }
    }

    private mutating func find(_ element: Point3D) -> Point3D {
        guard let parent = parents[element] else {
            parents[element] = element
            return element
        }

        if parent == element {
            return parent
        }

        let root = find(parent)
        // compress path
        parents[element] = root
        return root
    }

    var allSets: [Set<Point3D>] {
        var sets = [Point3D: Set<Point3D>]()

        for element in parents.keys {
            let root = root(of: element)
            sets[root, default: []].insert(element)
        }

        return Array(sets.values)
    }

    private func root(of element: Point3D) -> Point3D {
        // non-mutating version of find
        guard let parent = parents[element] else {
            return element
        }

        if parent == element {
            return parent
        }

        return root(of: parent)
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
            .init(input: .example, config: 10, part1: 40, part2: 25272),
        ]
    }
}
