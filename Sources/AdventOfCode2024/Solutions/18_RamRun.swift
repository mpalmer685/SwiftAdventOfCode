import AOCKit

struct RamRun: Puzzle {
    static let day = 18

    typealias Config = (memorySize: Int, droppedBytes: Int)

    func part1(input: Input) throws -> Int {
        try part1(input: input, (70, 1024))
    }

    func part1(input: Input, _ config: Config) throws -> Int {
        let (memorySize, droppedBytes) = config
        let corruptedBytes = input.lines.map { Point2D($0.integers) }
        let memorySpace = MemorySpace(
            size: memorySize,
            corruptedBytes: corruptedBytes[..<droppedBytes],
        )
        return memorySpace.safePath.count
    }

    func part2(input: Input) throws -> String {
        try part2(input: input, (70, 0))
    }

    func part2(input: Input, _ config: Config) throws -> String {
        let (memorySize, _) = config
        let corruptedBytes = input.lines.map { Point2D($0.integers) }

        let firstBlockedIndex = corruptedBytes.indices.partitioningIndex { index in
            let memorySpace = MemorySpace(
                size: memorySize,
                corruptedBytes: corruptedBytes[...index],
            )
            let path = memorySpace.safePath
            return path.isEmpty
        }

        let firstBlockedPoint = corruptedBytes[firstBlockedIndex]
        return "\(firstBlockedPoint.x),\(firstBlockedPoint.y)"
    }
}

private struct MemorySpace {
    private let bounds: ClosedRange<Int>
    private let corruptedBytes: Set<Point2D>

    init(size: Int, corruptedBytes: some Sequence<Point2D>) {
        bounds = 0 ... size
        self.corruptedBytes = Set(corruptedBytes)
    }

    var safePath: [Point2D] {
        let start = Point2D.zero
        let end = Point2D(x: bounds.upperBound, y: bounds.upperBound)
        return shortestPath(from: start, to: end)
    }
}

extension MemorySpace: Graph {
    func neighbors(of point: Point2D) -> [Point2D] {
        point.orthogonalNeighbors.filter { contains($0) && !corruptedBytes.contains($0) }
    }

    private func contains(_ point: Point2D) -> Bool {
        bounds.contains(point.x) && bounds.contains(point.y)
    }
}

extension RamRun: TestablePuzzleWithConfig {
    var testCases: [TestCaseWithConfig<Int, String, Config>] {
        [
            .given(.example, config: (6, 12)).expects(part1: 22, part2: "6,1"),
        ]
    }
}
