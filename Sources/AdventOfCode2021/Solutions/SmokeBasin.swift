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

    func part1(input: Input) throws -> Int {
        let grid = parseGrid(from: input)
        return grid.lowPoints.sum { 1 + grid.height(at: $0) }
    }

    func part2(input: Input) throws -> Int {
        let grid = parseGrid(from: input)
        return grid.lowPoints
            .map { grid.basinSize(startingAt: $0) }
            .max(count: 3)
            .product
    }

    private func parseGrid(from input: Input) -> Grid<Int> {
        Grid(input.lines.digits)
    }
}

private extension Grid where Cell == Int {
    func basinSize(startingAt start: Point2D) -> Int {
        var visited = Set<Point2D>()
        return basinSize(startingAt: start, visiting: &visited)
    }

    private func basinSize(
        startingAt start: Point2D,
        visiting visitedPoints: inout Set<Point2D>,
    ) -> Int {
        guard height(at: start) < 9, !visitedPoints.contains(start) else {
            return 0
        }

        visitedPoints.insert(start)

        return 1 + start.orthogonalNeighbors.sum { neighbor in
            basinSize(startingAt: neighbor, visiting: &visitedPoints)
        }
    }

    var lowPoints: [Point2D] {
        points.filter { isLowPoint(at: $0) }
    }

    private func isLowPoint(at point: Point2D) -> Bool {
        let heightAtPoint = height(at: point)
        return point.orthogonalNeighbors.allSatisfy { neighbor in
            heightAtPoint < height(at: neighbor)
        }
    }

    func height(at point: Point2D) -> Cell {
        guard contains(point) else { return 9 }
        return self[point]
    }
}
