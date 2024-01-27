import AOCKit

class HillClimbingAlgorithm: Puzzle {
    static let day = 12

    func part1(input: Input) throws -> Int {
        heightMap(from: input).shortestPath().count
    }

    func part2(input: Input) throws -> Int {
        let heightMap = heightMap(from: input)
        let starts = heightMap.grid.points.filter { heightMap.grid[$0] == "a" }
        return starts
            .map { heightMap.shortestPath(from: $0) }
            .filter(\.isNotEmpty)
            .min(of: \.count)!
    }

    private func heightMap(from input: Input) -> HeightMap {
        var start = Point2D.zero
        var end = Point2D.zero

        let cells = input.lines.enumerated().map { row, line in
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
    }
}

private struct HeightMap: Graph {
    let grid: Grid<Character>
    let start: Point2D
    let end: Point2D

    func neighbors(of state: Point2D) -> [Point2D] {
        let height = grid[state].alphabeticIndex!
        return state.orthogonalNeighbors.filter { neighbor in
            grid.contains(neighbor) && grid[neighbor].alphabeticIndex! <= height + 1
        }
    }

    func shortestPath() -> [Point2D] { shortestPath(from: start, to: end) }

    func shortestPath(from start: Point2D) -> [Point2D] { shortestPath(from: start, to: end) }
}
