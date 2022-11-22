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

    func part1() throws -> Int {
        let cells = parseInput()
        return findPath(in: Grid(cells))
    }

    func part2() throws -> Int {
        let cells = fill(grid: parseInput())
        return findPath(in: Grid(cells))
    }

    private func parseInput() -> [[Int]] {
        input().lines.digits
    }
}

private let adjacentCells = [
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1),
]

private func findPath(in grid: Grid<Int>) -> Int {
    let start = GridPoint(0, 0)
    let goal = GridPoint(grid.width - 1, grid.height - 1)
    var costs: [GridPoint: Int] = [start: 0]
    var heap = Heap<GridPoint> {
        costs[$0, default: .max] < costs[$1, default: .max]
    }
    heap.insert(start)

    while let node = heap.remove() {
        guard node != goal else { break }

        let neighbors = adjacentCells.map(node.offsetBy)

        guard let currentNodeCost = costs[node] else {
            fatalError("Could not find cost for node \(node)")
        }

        for neighbor in neighbors where grid.contains(neighbor) {
            let value = grid[neighbor]
            let costThroughCurrent = currentNodeCost + value

            if costThroughCurrent < costs[neighbor, default: .max] {
                costs[neighbor] = costThroughCurrent

                if let index = heap.index(of: neighbor) {
                    heap.replace(at: index, value: neighbor)
                } else {
                    heap.insert(neighbor)
                }
            }
        }
    }

    return costs[goal]!
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
