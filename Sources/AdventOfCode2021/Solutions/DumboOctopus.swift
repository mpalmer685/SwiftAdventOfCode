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

private struct Grid {
    struct Point: Hashable {
        let x: Int
        let y: Int

        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }

        func offsetBy(_ dx: Int, _ dy: Int) -> Self {
            Point(x + dx, y + dy)
        }
    }

    private var cells: [[Int]]

    init(_ cells: [[Int]]) {
        let width = cells[0].count
        guard cells.allSatisfy({ $0.count == width }) else {
            fatalError("Irregular row lengths")
        }
        self.cells = cells
    }

    var width: Int { cells[0].count }
    var height: Int { cells.count }

    var count: Int { height * width }

    var points: [Point] {
        cells.indices.flatMap { y in cells[y].indices.map { x in Point(x, y) } }
    }

    func contains(_ point: Point) -> Bool {
        point.x.isBetween(0, and: width - 1) && point.y.isBetween(0, and: height - 1)
    }

    subscript(_ point: Point) -> Int {
        get {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            return cells[point.y][point.x]
        }
        set {
            guard contains(point) else { fatalError("Out of bounds: \(point)") }
            cells[point.y][point.x] = newValue
        }
    }
}

extension Grid.Point: CustomStringConvertible {
    public var description: String { "(\(x), \(y))" }
}

extension Grid: CustomStringConvertible {
    public var description: String {
        cells.map { $0.map(String.init).joined() }.joined(separator: "\n")
    }
}
