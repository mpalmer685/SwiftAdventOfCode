import AOCKit

struct DumboOctopus: Puzzle {
    static let day = 11

    func part1(input: Input) throws -> Int {
        var grid = parseGrid(from: input)
        return (0 ..< 100).reduce(0) { flashes, _ in flashes + countFlashes(in: &grid) }
    }

    func part2(input: Input) throws -> Int {
        var grid = parseGrid(from: input)
        var cycles = 0
        repeat {
            cycles += 1
        } while countFlashes(in: &grid) < grid.count
        return cycles
    }

    private func parseGrid(from input: Input) -> Grid<Int> {
        let cells = input.lines.digits
        return Grid(cells)
    }
}

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
            for neighbor in point.neighbors where grid.contains(neighbor) {
                grid[neighbor] += 1
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
