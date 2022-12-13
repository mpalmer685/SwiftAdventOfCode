import AOCKit

class HillClimbingAlgorithm: Puzzle {
    static let day = 12

    func part1() throws -> Int {
        let (grid, start, end) = heightMap
        let path = grid.shortestPath(from: start, to: end)
        return path.count
    }

    func part2() throws -> Int {
        let (grid, _, end) = heightMap
        let starts = grid.points.filter { grid[$0] == "a" }

        return starts
            .map { grid.shortestPath(from: $0, to: end) }
            .map(\.count)
            .filter { $0 != 0 }
            .min()!
    }

    private lazy var heightMap = {
        var start = Point2D.zero
        var end = Point2D.zero

        let grid = input().lines.enumerated().map { row, line in
            line.characters.enumerated().map { col, char -> Character in
                if char == "S" {
                    start = Point2D(col, row)
                    return "a"
                }
                if char == "E" {
                    end = Point2D(col, row)
                    return "z"
                }
                return char
            }
        }

        return (Grid(grid), start, end)
    }()
}

private protocol Pathfinding {
    func neighbors(at point: Point2D) -> [Point2D]
}

extension Pathfinding {
    private typealias SearchState = (currentPath: [Point2D], next: Point2D)

    func shortestPath(from start: Point2D, to end: Point2D) -> [Point2D] {
        var queue = SimpleQueue<SearchState>()
        queue.push(([], start))

        var visited = Set<Point2D>()
        visited.insert(start)

        while let (path, node) = queue.pop() {
            if node == end {
                return path
            }

            for neighbor in neighbors(at: node) where !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.push((path + [node], neighbor))
            }
        }

        return []
    }
}

extension Grid: Pathfinding where Cell == Character {
    fileprivate func neighbors(at point: Point2D) -> [Point2D] {
        let height = self[point].alphabeticIndex!
        return point.neighbors.filter { neighbor in
            contains(neighbor) && self[neighbor].alphabeticIndex! <= height + 1
        }
    }
}

private typealias Point2D = Grid<Character>.Point

private extension Point2D {
    static var zero: Self { Self(0, 0) }

    var neighbors: [Point2D] {
        let directions = [
            (0, 1),
            (0, -1),
            (1, 0),
            (-1, 0),
        ]
        return directions.map { offsetBy($0.0, $0.1) }
    }
}

private struct SimpleQueue<Element> {
    private var elements: [Element] = []

    mutating func push(_ el: Element) {
        elements.insert(el, at: 0)
    }

    mutating func pop() -> Element? {
        elements.popLast()
    }
}
