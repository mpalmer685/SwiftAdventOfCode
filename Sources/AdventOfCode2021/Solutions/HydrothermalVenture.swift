import AOCKit

struct HydrothermalVenture: Puzzle {
    static let day = 5

    func part1() throws -> Int {
        let lines = parseInput()
        var field = Field()

        for (start, end) in lines where !isDiagonal(start, end) {
            for point in points(from: start, to: end) {
                field[point, default: 0] += 1
            }
        }

        return field.count { $0.value > 1 }
    }

    func part2() throws -> Int {
        let lines = parseInput()
        var field = Field()

        for (start, end) in lines {
            for point in points(from: start, to: end) {
                field[point, default: 0] += 1
            }
        }

        return field.count { $0.value > 1 }
    }

    private func parseInput() -> [(start: Point, end: Point)] {
        input().lines.map(parsePair)
    }
}

private typealias Field = [Point: Int]

private struct Point: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    init(input: Word) {
        let coords = input.words(separatedBy: ",")
        guard let x = coords[0].integer, let y = coords[1].integer else { fatalError() }

        self.x = x
        self.y = y
    }
}

private func points(from start: Point, to end: Point) -> [Point] {
    let dx = sign(end.x - start.x)
    let dy = sign(end.y - start.y)
    if isHorizontal(start, end) {
        return stride(from: start.x, through: end.x, by: dx).map { Point($0, start.y) }
    }
    if isVertical(start, end) {
        return stride(from: start.y, through: end.y, by: dy).map { Point(start.x, $0) }
    }
    return zip(
        stride(from: start.x, through: end.x, by: dx),
        stride(from: start.y, through: end.y, by: dy)
    ).map { Point($0.0, $0.1) }
}

private func sign(_ x: Int) -> Int {
    x == 0 ? 0 : x / abs(x)
}

private func parsePair(from line: Line) -> (start: Point, end: Point) {
    let parts = line.words(separatedBy: " -> ").map(Point.init)
    return (parts[0], parts[1])
}

private func isHorizontal(_ start: Point, _ end: Point) -> Bool {
    start.y == end.y
}

private func isVertical(_ start: Point, _ end: Point) -> Bool {
    start.x == end.x
}

private func isDiagonal(_ start: Point, _ end: Point) -> Bool {
    !isHorizontal(start, end) && !isVertical(start, end)
}
