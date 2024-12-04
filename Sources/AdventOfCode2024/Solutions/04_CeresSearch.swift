import AOCKit

struct CeresSearch: Puzzle {
    static let day = 4

    func part1(input: Input) throws -> Int {
        let grid = Grid(input.lines.characters)

        return grid.points.reduce(0) { sum, origin in
            sum + Vector2D.adjacents.count { direction in
                String(grid.take(4, from: origin, in: direction)) == "XMAS"
            }
        }
    }

    func part2(input: Input) throws -> Int {
        let grid = Grid(input.lines.characters)
        let searchTarget = Set(["MAS", "SAM"])

        return grid.points.count { center in
            guard grid[center] == "A" else { return false }

            let leftLeaning = grid.take(3, from: center + .topLeft, in: .bottomRight)
            let rightLeaning = grid.take(3, from: center + .topRight, in: .bottomLeft)

            return searchTarget.contains(String(leftLeaning))
                && searchTarget.contains(String(rightLeaning))
        }
    }
}

extension Grid {
    func take(_ count: Int, from start: Point2D, in direction: Point2D.Vector) -> [Cell] {
        guard contains(start) else { return [] }

        var current = start
        var result: [Cell] = [self[current]]
        for _ in 1 ..< count {
            current += direction
            guard contains(current) else { break }
            result.append(self[current])
        }
        return result
    }
}

private extension Vector2D {
    static var topLeft: Self { .init(-1, -1) }
    static var topRight: Self { .init(1, -1) }
    static var bottomLeft: Self { .init(-1, 1) }
    static var bottomRight: Self { .init(1, 1) }
}

extension CeresSearch: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example, part1: 18, part2: 9),
        ]
    }
}
