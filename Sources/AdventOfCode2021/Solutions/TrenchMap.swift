import AOCKit

struct TrenchMap: Puzzle {
    static let day = 20

    func part1() throws -> Int {
        var (algorithm, image) = parseInput()

        for round in 0 ..< 2 {
            let defaultPixel = round.isEven
                ? algorithm.contains(512)
                : algorithm.contains(0)
            image = image.enhanced(using: algorithm, withDefault: defaultPixel)
        }

        return image.pixels.count
    }

    func part2() throws -> Int {
        var (algorithm, image) = parseInput()

        for round in 0 ..< 50 {
            let defaultPixel = round.isEven
                ? algorithm.contains(512)
                : algorithm.contains(0)
            image = image.enhanced(using: algorithm, withDefault: defaultPixel)
        }

        return image.pixels.count
    }

    private func parseInput() -> (EnhancementAlgorithm, Image) {
        let parts = input().lines.split(whereSeparator: \.isEmpty)

        guard parts.count == 2 else { fatalError() }
        guard parts[0].count == 1 else { fatalError() }

        let algorithm: EnhancementAlgorithm = parts[0][0].characters.enumerated()
            .reduce(into: []) { a, pair in
                if pair.element == "#" {
                    a.insert(pair.offset)
                }
            }

        let image = parseImage(from: parts[1].raw)

        return (algorithm, image)
    }
}

private func parseImage(from lines: [String]) -> Image {
    let height = lines.count
    let width = lines[0].count
    let bounds = Rect(topLeft: Point(x: 0, y: 0), bottomRight: Point(x: width - 1, y: height - 1))
    let pixels: Set<Point> = bounds.points.reduce(into: []) { pixels, point in
        if lines[point.y][point.x] == "#" {
            pixels.insert(point)
        }
    }

    return Image(bounds: bounds, pixels: pixels)
}

private typealias EnhancementAlgorithm = Set<Int>

private struct Point: Hashable {
    let x: Int
    let y: Int

    var neighbors: [Point] {
        let offsets = [
            (-1, -1),
            (0, -1),
            (1, -1),
            (-1, 0),
            (0, 0),
            (1, 0),
            (-1, 1),
            (0, 1),
            (1, 1),
        ]
        return offsets.map { offset(by: $0) }
    }

    func offset(by offset: (Int, Int)) -> Point {
        let (dx, dy) = offset
        return Point(x: x + dx, y: y + dy)
    }
}

private struct Rect {
    let topLeft: Point
    let bottomRight: Point

    var left: Int { topLeft.x }
    var right: Int { bottomRight.x }
    var top: Int { topLeft.y }
    var bottom: Int { bottomRight.y }

    var width: Int { right - left }
    var height: Int { bottom - top }

    var points: [Point] {
        (left ... right).flatMap { x in
            (top ... bottom).map { y in
                Point(x: x, y: y)
            }
        }
    }

    func contains(_ point: Point) -> Bool {
        point.x.isBetween(left, and: right) && point.y.isBetween(top, and: bottom)
    }
}

private struct Image {
    let bounds: Rect
    let pixels: Set<Point>

    func enhanced(using algorithm: EnhancementAlgorithm, withDefault defaultPixel: Bool) -> Image {
        let newBounds = Rect(
            topLeft: bounds.topLeft.offset(by: (-1, -1)),
            bottomRight: bounds.bottomRight.offset(by: (1, 1))
        )
        var newPixels: Set<Point> = []
        for point in newBounds.points {
            let index = algorithmIndex(for: point, withDefault: defaultPixel)
            if algorithm.contains(index) {
                newPixels.insert(point)
            }
        }
        return Image(bounds: newBounds, pixels: newPixels)
    }

    private func algorithmIndex(for point: Point, withDefault defaultPixel: Bool) -> Int {
        let binary = point.neighbors.map { p in
            if bounds.contains(p) {
                return pixels.contains(p) ? "1" : "0"
            } else {
                return defaultPixel ? "1" : "0"
            }
        }.joined()
        guard let index = Int(binary, radix: 2) else { fatalError("Got \(binary)") }
        return index
    }
}

private extension Int {
    var isEven: Bool { self % 2 == 0 }
    var isOdd: Bool { self % 2 == 1 }
}

// swiftlint:disable line_length
private let testInput = """
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
"""
