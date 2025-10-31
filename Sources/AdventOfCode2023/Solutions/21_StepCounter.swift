import AOCKit

struct StepCounter: Puzzle {
    static let day = 21

    // static let rawInput: String? = """
    // ...........
    // .....###.#.
    // .###.##..#.
    // ..#.#...#..
    // ....#.#....
    // .##..S####.
    // .##..#...#.
    // .......##..
    // .##.#.####.
    // .##..##.##.
    // ...........
    // """

    func part1(input: Input) throws -> Int {
        let targetStepCount = 64
        let (start, openSpots) = parse(input)
        let pathfinder = StepPathfinder(openPlots: openSpots)
        let costs = pathfinder.nodesAccessible(from: start)

        return costs.values.count { steps in
            steps <= targetStepCount && steps.isEven == targetStepCount.isEven
        }
    }

    // credit to
    // https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
    func part2(input: Input) throws -> Int {
        let targetStepCount = 26_501_365
        let grid = Grid(input.lines.characters)
        let (start, openSpots) = parse(input)
        let pathfinder = StepPathfinder(openPlots: openSpots)
        let costs = pathfinder.nodesAccessible(from: start)

        let evenCorners = costs.values.count { $0.isEven && $0 > 65 }
        let oddCorners = costs.values.count { $0.isOdd && $0 > 65 }

        let evenFull = costs.values.count(where: \.isEven)
        let oddFull = costs.values.count(where: \.isOdd)

        assert(
            grid.width == grid.height,
            "Expected input to be a square, but got \(grid.width) x \(grid.height)",
        )
        let size = grid.width
        let n = ((targetStepCount - (size / 2)) / size)
        assert(n == 202_300, "Expected 202300 but got \(n)")

        return ((n + 1) * (n + 1)) * oddFull
            + (n * n) * evenFull
            - (n + 1) * oddCorners
            + n * evenCorners
    }

    private func parse(_ input: Input) -> (Point2D, Set<Point2D>) {
        let grid = Grid(input.lines.characters)
        guard let start = grid.points.first(where: { grid[$0] == "S" }) else {
            fatalError()
        }
        let openSpots = Set(grid.points.filter { grid[$0] != "#" })

        return (start, openSpots)
    }
}

private struct StepPathfinder: Graph {
    let openPlots: Set<Point2D>

    func neighbors(of position: Point2D) -> [Point2D] {
        position.orthogonalNeighbors.filter { openPlots.contains($0) }
    }
}
