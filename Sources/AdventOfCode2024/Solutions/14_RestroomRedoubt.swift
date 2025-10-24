import AOCKit

struct RestroomRedoubt: Puzzle {
    static let day = 14

    func part1(input: Input) throws -> Int {
        try part1(input: input, Simulation.size)
    }

    func part1(input: Input, _ size: (width: Int, height: Int)) throws -> Int {
        Simulation.parse(from: input, size: size).safetyScore(at: 100)
    }

    func part2(input: Input) async throws -> Int {
        try await part2(input: input, Simulation.size)
    }

    func part2(input: Input, _ size: (width: Int, height: Int)) async throws -> Int {
        let simulation = Simulation.parse(from: input, size: size)
        let scores = await (1 ..< size.width * size.height).concurrentMap { seconds in
            (seconds: seconds, score: simulation.safetyScore(at: seconds))
        }

        return scores.min(by: \.score)!.seconds
    }
}

private struct Simulation {
    static let size = (101, 103)

    static func parse(from input: Input, size: (Int, Int)) -> Self {
        let pattern = /p=(?<x>\d+),(?<y>\d+) v=(?<dx>-?\d+),(?<dy>-?\d+)/
        let robots = input.lines.map { line in
            guard let match = try? pattern.wholeMatch(in: line.raw)?.output else {
                fatalError("Invalid input line: \(line)")
            }
            return Robot(
                position: Point2D(Int(match.x)!, Int(match.y)!),
                velocity: Vector2D(Int(match.dx)!, Int(match.dy)!),
            )
        }
        return Self(robots: robots, size: size)
    }

    private let robots: [Robot]
    private let size: (width: Int, height: Int)

    func safetyScore(at tick: Int) -> Int {
        let positionsAtTick = robots
            .map { $0.position + $0.velocity * tick }
            .map { (x: $0.x.wrapped(to: 0 ..< size.width), y: $0.y.wrapped(to: 0 ..< size.height)) }

        var counts = (topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)
        // for (x, y) in positionsAtTick where x != size.width / 2 && y != size.height / 2 {
        //     if x < size.width / 2 {
        //         if y < size.height / 2 {
        //             counts.topLeft += 1
        //         } else if y > size.height / 2 {
        //             counts.bottomLeft += 1
        //         }
        //     } else if x > size.width / 2 {
        //         if y < size.height / 2 {
        //             counts.topRight += 1
        //         } else if y > size.height / 2 {
        //             counts.bottomRight += 1
        //         }
        //     }
        // }
        for p in positionsAtTick {
            switch p {
                case (0 ..< size.width / 2, 0 ..< size.height / 2):
                    counts.topLeft += 1
                case (0 ..< size.width / 2, (size.height / 2) + 1 ..< size.height):
                    counts.bottomLeft += 1
                case ((size.width / 2) + 1 ..< size.width, 0 ..< size.height / 2):
                    counts.topRight += 1
                case ((size.width / 2) + 1 ..< size.width, (size.height / 2) + 1 ..< size.height):
                    counts.bottomRight += 1
                default:
                    continue
            }
        }

        return counts.topLeft * counts.topRight * counts.bottomLeft * counts.bottomRight
    }
}

private struct Robot: Hashable {
    let position: Point2D
    let velocity: Vector2D
}

private extension Int {
    func wrapped(to range: Range<Self>) -> Self {
        let distance = range.upperBound - range.lowerBound
        return ((self - range.lowerBound) % distance + distance) % distance + range.lowerBound
    }
}

extension RestroomRedoubt: TestablePuzzleWithConfig {
    var testCases: [TestCaseWithConfig<Int, Int, (width: Int, height: Int)>] {
        [
            .init(input: .example, config: (11, 7), part1: 12),
        ]
    }
}
