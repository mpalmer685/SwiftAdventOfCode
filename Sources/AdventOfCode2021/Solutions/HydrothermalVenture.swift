import AOCKit

struct HydrothermalVenture: Puzzle {
    static let day = 5

    func part1() throws -> Int {
        let lines = parseInput()
        var field = Field()

        for line in lines where !line.isDiagonal {
            for point in line.points {
                field[point, default: 0] += 1
            }
        }

        return field.count { $0.value > 1 }
    }

    func part2() throws -> Int {
        let lines = parseInput()
        var field = Field()

        for line in lines {
            for point in line.points {
                field[point, default: 0] += 1
            }
        }

        return field.count { $0.value > 1 }
    }

    private func parseInput() -> [Line] {
        input().lines.map(Line.init)
    }
}

private typealias Field = [Point2D: Int]

private extension Point2D {
    init(input: Word) {
        let coords = input.words(separatedBy: ",")
        guard let x = coords[0].integer, let y = coords[1].integer else { fatalError() }

        self.init(x, y)
    }
}

private struct Line {
    let start: Point2D
    let end: Point2D

    init(_ line: AOCKit.Line) {
        let parts = line.words(separatedBy: " -> ").map(Point2D.init)
        start = parts[0]
        end = parts[1]
    }

    var isHorizontal: Bool { start.y == end.y }
    var isVertical: Bool { start.x == end.x }
    var isDiagonal: Bool { !isHorizontal && !isVertical }

    var points: [Point2D] {
        let dx = (end.x - start.x).signum()
        let dy = (end.y - start.y).signum()
        if isHorizontal {
            return stride(from: start.x, through: end.x, by: dx).map { Point2D($0, start.y) }
        }
        if isVertical {
            return stride(from: start.y, through: end.y, by: dy).map { Point2D(start.x, $0) }
        }
        guard abs(end.x - start.x) == abs(end.y - start.y) else {
            fatalError("Line is not a 45 degree diagonal.")
        }
        return zip(
            stride(from: start.x, through: end.x, by: dx),
            stride(from: start.y, through: end.y, by: dy)
        ).map { Point2D($0, $1) }
    }
}
