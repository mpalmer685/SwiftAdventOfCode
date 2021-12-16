import AOCKit

struct DumboOctopus: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        var grid = parseGrid(from: input)
        return (0 ..< 100).reduce(0) { flashes, _ in flashes + countFlashes(in: &grid) }
    }

    func part2Solution(for input: String) throws -> Int {
        var grid = parseGrid(from: input)
        var cycles = 0
        repeat {
            cycles += 1
        } while countFlashes(in: &grid) < grid.count
        return cycles
    }

    private func parseGrid(from input: String) -> Grid {
        let cells = getLines(from: input).map { line in
            Array(line).map(String.init).compactMap(Int.init)
        }
        return Grid(cells)
    }
}

private let adjacentCells = [
    (-1, -1),
    (0, -1),
    (1, -1),
    (-1, 0),
    (1, 0),
    (-1, 1),
    (0, 1),
    (1, 1),
]

private func countFlashes(in grid: inout Grid) -> Int {
    for point in grid.points {
        grid[point] += 1
    }

    var flashed = Set<Grid.Point>()
    while true {
        var hasFlashed = false
        for point in grid.points where grid[point] > 9 && !flashed.contains(point) {
            flashed.insert(point)
            hasFlashed = true
            for (dx, dy) in adjacentCells {
                let adjacent = point.offsetBy(dx, dy)
                guard grid.contains(adjacent) else { continue }
                grid[adjacent] += 1
            }
        }
        if !hasFlashed {
            break
        }
    }

    for point in flashed {
        grid[point] = 0
    }

    return flashed.count
}
