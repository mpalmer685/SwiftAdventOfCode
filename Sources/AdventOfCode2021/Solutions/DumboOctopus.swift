import AOCKit

struct DumboOctopus: Puzzle {
    static let day = 11

    func part1() throws -> Int {
        var grid = parseGrid()
        return (0 ..< 100).reduce(0) { flashes, _ in flashes + countFlashes(in: &grid) }
    }

    func part2() throws -> Int {
        var grid = parseGrid()
        var cycles = 0
        repeat {
            cycles += 1
        } while countFlashes(in: &grid) < grid.count
        return cycles
    }

    private func parseGrid() -> Grid<Int> {
        let cells = input().lines.digits
        return Grid(cells)
    }
}

private let adjacentVectors = [
    Vector2D(-1, -1),
    Vector2D(0, -1),
    Vector2D(1, -1),
    Vector2D(-1, 0),
    Vector2D(1, 0),
    Vector2D(-1, 1),
    Vector2D(0, 1),
    Vector2D(1, 1),
]

private func countFlashes(in grid: inout Grid<Int>) -> Int {
    for point in grid.points {
        grid[point] += 1
    }

    var flashed = Set<Point2D>()
    while true {
        var hasFlashed = false
        for point in grid.points where grid[point] > 9 && !flashed.contains(point) {
            flashed.insert(point)
            hasFlashed = true
            for v in adjacentVectors {
                let adjacent = point.offset(by: v)
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
