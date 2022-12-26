import AOCKit

class HillClimbingAlgorithm: Puzzle {
    static let day = 12

    func part1() throws -> Int {
        heightMap.shortestPath().count
    }

    func part2() throws -> Int {
        let starts = heightMap.grid.points.filter { heightMap.grid[$0] == "a" }
        return starts
            .map { heightMap.shortestPath(from: $0) }
            .map(\.count)
            .filter { $0 != 0 }
            .min()!
    }

    private lazy var heightMap: HeightMap = {
        var start = Point2D.zero
        var end = Point2D.zero

        let cells = input().lines.enumerated().map { row, line in
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

        return .init(grid: Grid(cells), start: start, end: end)
    }()
}

private struct HeightMap: PathfindingGraph {
    let grid: Grid<Character>
    let start: Point2D
    let end: Point2D

    func nextStates(from state: Point2D) -> [Point2D] {
        let height = grid[state].alphabeticIndex!
        return state.neighbors.filter { neighbor in
            grid.contains(neighbor) && grid[neighbor].alphabeticIndex! <= height + 1
        }
    }

    func shortestPath() -> [Point2D] { shortestPath(from: start, to: end) }

    func shortestPath(from start: Point2D) -> [Point2D] { shortestPath(from: start, to: end) }

    private func shortestPath(from start: Point2D, to end: Point2D) -> [Point2D] {
        let pathfinder = BreadthFirstSearch(self)
        return pathfinder.path(from: start, to: end)
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
