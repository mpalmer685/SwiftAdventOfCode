import AOCKit

struct SandSlabs: Puzzle {
    static let day = 22

    // static let rawInput: String? = """
    // 1,0,1~1,2,1
    // 0,0,2~2,0,2
    // 0,2,3~2,2,3
    // 0,0,4~0,2,4
    // 2,0,5~2,2,5
    // 0,1,6~2,1,6
    // 1,1,8~1,1,9
    // """

    func part1(input: Input) throws -> Int {
        let bricks = input.lines.map(Brick.init)
        let (_, supportedBy) = dropAll(bricks)

        let unsafeIndices: Set<Int> = supportedBy.reduce(into: []) { unsafe, indices in
            if indices.count == 1 {
                unsafe.insert(indices.first!)
            }
        }

        return supportedBy.count - unsafeIndices.count
    }

    func part2(input: Input) throws -> Int {
        let bricks = input.lines.map(Brick.init)
        let (supports, supportedBy) = dropAll(bricks)

        let unsafeIndices: Set<Int> = supportedBy.reduce(into: []) { unsafe, indices in
            if indices.count == 1 {
                unsafe.insert(indices.first!)
            }
        }

        return unsafeIndices.sum { start in
            var remaining: Queue<Int> = [start]
            var removed: Set<Int> = [start]

            var result = 0
            while let current = remaining.pop() {
                for supported in supports[current]
                    where !removed.contains(supported) &&
                    supportedBy[supported].allSatisfy({ removed.contains($0) })
                {
                    result += 1
                    removed.insert(supported)
                    remaining.push(supported)
                }
            }
            return result
        }
    }

    private func dropAll(_ bricks: [Brick]) -> (supports: [Set<Int>], supportedBy: [Set<Int>]) {
        var heights = [Point2D: Int]()
        var indices = [Point2D: Int]()
        var supports: [Set<Int>] = Array(repeating: [], count: bricks.count)
        var supportedBy: [Set<Int>] = Array(repeating: [], count: bricks.count)

        for (index, brick) in bricks.sorted(using: \.zMin).enumerated() {
            let height = brick.zMax - brick.zMin + 1

            let top = brick.xyPoints.max { heights[$0] ?? 0 }!

            for point in brick.xyPoints {
                if heights[point] == top, let supportIndex = indices[point] {
                    supports[supportIndex].insert(index)
                    supportedBy[index].insert(supportIndex)
                }

                heights[point] = top + height
                indices[point] = index
            }
        }

        return (supports, supportedBy)
    }
}

private struct Brick: Equatable {
    let xyPoints: Set<Point2D>
    let zMin: Int
    let zMax: Int

    init(xRange: ClosedRange<Int>, yRange: ClosedRange<Int>, zRange: ClosedRange<Int>) {
        zMin = zRange.lowerBound
        zMax = zRange.upperBound

        let points = xRange.flatMap { x in
            yRange.map { y in Point2D(x, y) }
        }
        xyPoints = Set(points)
    }

    init(_ line: Line) {
        let parts = line.words(separatedBy: "~")
        let start = parts[0].words(separatedBy: .comma).integers
        let end = parts[1].words(separatedBy: .comma).integers
        let ranges = zip(start, end).map { $0 ... $1 }
        self.init(xRange: ranges[0], yRange: ranges[1], zRange: ranges[2])
    }
}
