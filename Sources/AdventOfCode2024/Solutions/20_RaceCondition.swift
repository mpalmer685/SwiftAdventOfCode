import AOCKit

struct RaceCondition: Puzzle {
    static let day = 20

    func part1(input: Input) throws -> Int {
        try part1(input: input, 100)
    }

    func part1(input: Input, _ minimumImprovement: Int) throws -> Int {
        let grid = Grid(input.lines.characters)
        let distances = calculateDistancesToEnd(in: grid)

        return grid.points.count { point in
            guard grid[point] == "#" else { return false }

            let neighbors = point.orthogonalNeighbors.filter { neighbor in
                grid.contains(neighbor) && grid[neighbor] != "#"
            }
            guard neighbors.count == 2 else { return false }

            let (a, b) = (neighbors[0], neighbors[1])

            guard let distanceA = distances[a], let distanceB = distances[b] else {
                return false
            }
            guard max(distanceA, distanceB) >= minimumImprovement else {
                return false
            }

            return abs(distanceA - distanceB) - 2 >= minimumImprovement
        }
    }

    func part2(input: Input) throws -> Int {
        try part2(input: input, 100)
    }

    func part2(input: Input, _ minimumImprovement: Int) throws -> Int {
        let grid = Grid(input.lines.characters)
        let distances = calculateDistancesToEnd(in: grid)
        return distances.combinations(ofCount: 2).count { pair in
            let (a, distanceA) = pair[0]
            let (b, distanceB) = pair[1]
            guard max(distanceA, distanceB) >= minimumImprovement else {
                return false
            }

            let distanceBetween = a.manhattanDistance(to: b)
            guard distanceBetween <= 20 else { return false }

            return abs(distanceA - distanceB) - distanceBetween >= minimumImprovement
        }
    }

    private func calculateDistancesToEnd(in grid: Grid<Character>) -> [Point2D: Int] {
        guard let start = grid.location(of: "S") else {
            fatalError("No start found")
        }
        guard let end = grid.location(of: "E") else {
            fatalError("No end found")
        }

        var distances = [Point2D: Int]()
        var current = end
        var currentDistance = 0

        while current != start {
            distances[current] = currentDistance
            currentDistance += 1

            let neighbors = current.orthogonalNeighbors.filter { neighbor in
                grid.contains(neighbor) && grid[neighbor] != "#" && distances[neighbor] == nil
            }
            assert(
                neighbors.count == 1,
                "Expected 1 neighbor at \(current), got \(neighbors.count)",
            )

            current = neighbors[0]
        }

        assert(current == start)
        distances[current] = currentDistance

        return distances
    }
}

extension RaceCondition: TestablePuzzleWithConfig {
    var testCases: [TestCaseWithConfig<Int, Int, Int>] {
        [
            .init(input: .example, config: 10, part1: 10),
            .init(input: .example, config: 50, part2: 285),
        ]
    }
}
