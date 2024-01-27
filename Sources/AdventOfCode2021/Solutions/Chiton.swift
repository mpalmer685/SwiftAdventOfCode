import AOCKit

private let testInput = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
"""

struct Chiton: Puzzle {
    static let day = 15

    func part1(input: Input) throws -> Int {
        let grid = Grid(parse(input))
        return Cave(grid).riskOfBestPath()
    }

    func part2(input: Input) throws -> Int {
        let grid = Grid(fill(grid: parse(input)))
        return Cave(grid).riskOfBestPath()
    }

    private func parse(_ input: Input) -> [[Int]] {
        input.lines.digits
    }
}

private struct Cave {
    private let grid: Grid<Int>

    init(_ grid: Grid<Int>) {
        self.grid = grid
    }

    func riskOfBestPath() -> Int {
        let start = Point2D(0, 0)
        let goal = Point2D(grid.width - 1, grid.height - 1)
        return costOfPath(from: start, to: goal)
    }
}

extension Cave: WeightedGraph {
    func neighbors(of state: Point2D) -> [(Point2D, Int)] {
        state.orthogonalNeighbors
            .filter { grid.contains($0) }
            .map { ($0, grid[$0]) }
    }
}

private func fill(grid: [[Int]]) -> [[Int]] {
    func increaseRisk(_ risk: Int, by increase: Int) -> Int {
        (risk + increase - 1) % 9 + 1
    }

    var grid = grid

    for y in grid.indices {
        grid[y] = (0 ..< 5).flatMap { amt in grid[y].map { increaseRisk($0, by: amt) } }
    }

    let original = grid

    for amt in 1 ..< 5 {
        grid += original.map { row in row.map { increaseRisk($0, by: amt) } }
    }

    return grid
}
