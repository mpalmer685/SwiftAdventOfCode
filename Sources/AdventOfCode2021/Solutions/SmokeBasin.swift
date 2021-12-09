import AOCKit

private let testInput = """
2199943210
3987894921
9856789892
8767896789
9899965678
"""

struct SmokeBasin: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let grid = parseGrid(from: input)

        return findLowPoints(in: grid)
            .map { 1 + heightAt(point: $0, in: grid) }
            .reduce(0, +)
    }

    func part2Solution(for input: String) throws -> Int {
        let grid = parseGrid(from: input)
        let lowPoints = findLowPoints(in: grid)
        let sizes = lowPoints.map { getBasinSize(in: grid, startingAt: $0) }.sorted(by: >)

        return sizes.prefix(3).reduce(1, *)
    }

    private func parseGrid(from input: String) -> [[Int]] {
        getLines(from: input)
            .map(Array.init)
            .map { row in row.compactMap { Int(String($0)) }}
    }
}

private struct Point: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    func offsetBy(_ dx: Int, _ dy: Int) -> Self {
        Point(x + dx, y + dy)
    }

    func isWithin<T>(boundsOf grid: [[T]]) -> Bool {
        y >= 0 && y < grid.count && x >= 0 && x < grid[y].count
    }
}

private func getBasinSize(in grid: [[Int]], startingAt startingPoint: Point) -> Int {
    var visited = Set<Point>()
    return getBasinSize(in: grid, startingAt: startingPoint, visiting: &visited)
}

private func getBasinSize(
    in grid: [[Int]],
    startingAt startingPoint: Point,
    visiting visitedPoints: inout Set<Point>
) -> Int {
    guard heightAt(point: startingPoint, in: grid) < 9,
          !visitedPoints.contains(startingPoint)
    else {
        return 0
    }

    visitedPoints.insert(startingPoint)

    return adjacentCells.reduce(1) { sum, offset in
        sum + getBasinSize(
            in: grid,
            startingAt: startingPoint.offsetBy(offset.0, offset.1),
            visiting: &visitedPoints
        )
    }
}

private func findLowPoints(in grid: [[Int]]) -> [Point] {
    let gridHeight = grid.count
    let gridWidth = grid[0].count

    var lowPoints = [Point]()
    for y in 0 ..< gridHeight {
        for x in 0 ..< gridWidth {
            if isLowPoint(Point(x, y), in: grid) {
                lowPoints.append(Point(x, y))
            }
        }
    }
    return lowPoints
}

private let adjacentCells: [(Int, Int)] = [
    (0, -1),
    (0, 1),
    (-1, 0),
    (1, 0),
]

private func isLowPoint(_ point: Point, in grid: [[Int]]) -> Bool {
    let heightAtPoint = heightAt(point: point, in: grid)
    for (dx, dy) in adjacentCells {
        let comparisonHeight = heightAt(point: point.offsetBy(dx, dy), in: grid)
        if comparisonHeight <= heightAtPoint {
            return false
        }
    }
    return true
}

private func heightAt(point: Point, in grid: [[Int]]) -> Int {
    guard point.isWithin(boundsOf: grid) else { return 9 }
    return grid[point.y][point.x]
}
