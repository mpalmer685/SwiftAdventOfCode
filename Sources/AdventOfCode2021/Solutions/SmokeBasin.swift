import AOCKit

private let testInput = """
2199943210
3987894921
9856789892
8767896789
9899965678
"""

struct SmokeBasin: Puzzle {
    static let day = 9

    func part1() throws -> Int {
        let grid = parseGrid()

        return findLowPoints(in: grid)
            .map { 1 + heightAt(point: $0, in: grid) }
            .reduce(0, +)
    }

    func part2() throws -> Int {
        let grid = parseGrid()
        let lowPoints = findLowPoints(in: grid)
        let sizes = lowPoints.map { getBasinSize(in: grid, startingAt: $0) }.sorted(by: >)

        return sizes.prefix(3).reduce(1, *)
    }

    private func parseGrid() -> Grid<Int> {
        Grid(input().lines.digits)
    }
}

private func getBasinSize(in grid: Grid<Int>, startingAt startingPoint: Point2D) -> Int {
    var visited = Set<Point2D>()
    return getBasinSize(in: grid, startingAt: startingPoint, visiting: &visited)
}

private func getBasinSize(
    in grid: Grid<Int>,
    startingAt startingPoint: Point2D,
    visiting visitedPoints: inout Set<Point2D>
) -> Int {
    guard heightAt(point: startingPoint, in: grid) < 9,
          !visitedPoints.contains(startingPoint)
    else {
        return 0
    }

    visitedPoints.insert(startingPoint)

    return startingPoint.orthogonalNeighbors.reduce(1) { sum, neighbor in
        sum + getBasinSize(
            in: grid,
            startingAt: neighbor,
            visiting: &visitedPoints
        )
    }
}

private func findLowPoints(in grid: Grid<Int>) -> [Point2D] {
    var lowPoints = [Point2D]()
    for p in grid.points where isLowPoint(p, in: grid) {
        lowPoints.append(p)
    }
    return lowPoints
}

private func isLowPoint(_ point: Point2D, in grid: Grid<Int>) -> Bool {
    let heightAtPoint = heightAt(point: point, in: grid)
    for neighbor in point.orthogonalNeighbors {
        let comparisonHeight = heightAt(point: neighbor, in: grid)
        if comparisonHeight <= heightAtPoint {
            return false
        }
    }
    return true
}

private func heightAt(point: Point2D, in grid: Grid<Int>) -> Int {
    guard grid.contains(point) else { return 9 }
    return grid[point]
}
