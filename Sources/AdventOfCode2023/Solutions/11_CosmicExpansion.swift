import AOCKit

struct CosmicExpansion: Puzzle {
    static let day = 11

    func part1(input: Input) throws -> Int {
        let galaxies = parse(input)
        let expanded = expand(galaxies, byFactorOf: 2)

        return expanded.combinations(ofCount: 2).sum(of: \.manhattanDistance)
    }

    func part2(input: Input) throws -> Int {
        let galaxies = parse(input)
        let expanded = expand(galaxies, byFactorOf: 1_000_000)

        return expanded.combinations(ofCount: 2).sum(of: \.manhattanDistance)
    }

    private func parse(_ input: Input) -> Set<Point2D> {
        let grid = Grid(input.lines.characters)
        return Set(grid.points.filter { grid[$0] == "#" })
    }

    private func expand(_ galaxies: Set<Point2D>, byFactorOf multiplier: Int) -> Set<Point2D> {
        guard let height = galaxies.max(of: \.y), let width = galaxies.max(of: \.x) else {
            fatalError()
        }
        let emptyRows = Array(0 ..< height).filter { row in
            !galaxies.contains(where: { $0.y == row })
        }
        let emptyColumns = Array(0 ..< width).filter { col in
            !galaxies.contains(where: { $0.x == col })
        }

        let expanded = galaxies.map { point in
            let rowExpandCount = emptyRows.count { $0 < point.y }
            let colExpandCount = emptyColumns.count { $0 < point.x }

            let e = Point2D(
                point.x + (multiplier - 1) * colExpandCount,
                point.y + (multiplier - 1) * rowExpandCount,
            )
            return e
        }

        return Set(expanded)
    }
}

private extension [Point2D] {
    var manhattanDistance: Int {
        adjacentPairs().sum { $0.manhattanDistance(to: $1) }
    }
}
