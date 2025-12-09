import AOCKit

struct MovieTheater: Puzzle {
    static let day = 9

    func part1(input: Input) async throws -> Int {
        input.lines.map { Point2D($0.csvWords.integers) }
            .combinations(ofCount: 2)
            .map(Rectangle.init)
            .max(of: \.area)!
    }

    func part2(input: Input) async throws -> Int {
        let tiles = input.lines.map { Point2D($0.csvWords.integers) }
        let polygon = Polygon(vertices: tiles)
        let rectangles = tiles
            .combinations(ofCount: 2)
            .map(Rectangle.init)

        return rectangles
            .filter { !polygon.intersects(with: $0) }
            .max(of: \.area)!
    }

    private func areaOfRectangle(spanningFrom first: Point2D, to second: Point2D) -> Int {
        let width = abs(second.x - first.x) + 1
        let height = abs(second.y - first.y) + 1
        return width * height
    }
}

private struct Rectangle {
    let xMin: Int
    let xMax: Int
    let yMin: Int
    let yMax: Int

    init(_ combination: [Point2D]) {
        let (first, second) = (combination[0], combination[1])
        xMin = min(first.x, second.x)
        xMax = max(first.x, second.x)
        yMin = min(first.y, second.y)
        yMax = max(first.y, second.y)
    }

    var area: Int {
        let width = xMax - xMin + 1
        let height = yMax - yMin + 1
        return width * height
    }
}

private struct Polygon {
    let edges: [Edge]

    init(vertices: [Point2D]) {
        edges = (vertices + [vertices[0]])
            .adjacentPairs()
            .map { Edge(
                xMin: min($0.0.x, $0.1.x),
                xMax: max($0.0.x, $0.1.x),
                yMin: min($0.0.y, $0.1.y),
                yMax: max($0.0.y, $0.1.y),
            ) }
    }

    func intersects(with rectangle: Rectangle) -> Bool {
        edges.contains { edge in
            rectangle.xMin < edge.xMax && rectangle.xMax > edge.xMin &&
                rectangle.yMin < edge.yMax && rectangle.yMax > edge.yMin
        }
    }

    struct Edge {
        let xMin: Int
        let xMax: Int
        let yMin: Int
        let yMax: Int
    }
}

extension MovieTheater: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 50, part2: 24),
        ]
    }
}
