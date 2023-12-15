import AOCKit

struct PointOfIncidence: Puzzle {
    static let day = 13

    // static let rawInput: String? = """
    // #...##..#
    // #....#..#
    // ..##..###
    // #####.##.
    // #####.##.
    // ..##..###
    // #....#..#

    // #.##..##.
    // ..#.##.#.
    // ##......#
    // ##......#
    // ..#.##.#.
    // ..##..##.
    // #.#.##.#.
    // """

    func part1(input: Input) throws -> Int {
        let reflections = parse(input).map { grid in
            reflection(in: grid, using: ==)
        }
        return summarize(reflections)
    }

    func part2(input: Input) throws -> Int {
        let reflections = parse(input).map { grid in
            reflection(in: grid) { first, second in
                let pairs = zip(first.flattened, second.flattened)
                return pairs.count(where: !=) == 1
            }
        }
        return summarize(reflections)
    }

    private func reflection(
        in grid: Grid<Character>,
        using check: ([[Character]], [[Character]]) -> Bool
    ) -> Reflection {
        for row in 1 ..< grid.height {
            let length = min(row, grid.height - row)
            let above = grid[rows: row - length ..< row]
            let below = grid[rows: row ..< row + length]
            if check(above, below.reversed()) {
                return .horizontal(row)
            }
        }

        for col in 1 ..< grid.width {
            let length = min(col, grid.width - col)
            let left = grid[columns: col - length ..< col]
            let right = grid[columns: col ..< col + length]
            if check(left, right.reversed()) {
                return .vertical(col)
            }
        }

        fatalError("Did not find a reflection")
    }

    private func summarize(_ reflections: [Reflection]) -> Int {
        let columnCount = reflections.sum {
            if case let .vertical(column) = $0 {
                return column
            } else {
                return 0
            }
        }
        let rowCount = reflections.sum {
            if case let .horizontal(row) = $0 {
                return row
            } else {
                return 0
            }
        }

        return 100 * rowCount + columnCount
    }

    private func parse(_ input: Input) -> [Grid<Character>] {
        var grids = [Grid<Character>]()
        var currentGroup = [Line]()
        for line in input.lines {
            if line.isEmpty {
                grids.append(Grid(currentGroup.characters))
                currentGroup = []
            } else {
                currentGroup.append(line)
            }
        }
        grids.append(Grid(currentGroup.characters))
        return grids
    }
}

private enum Reflection {
    case vertical(Int)
    case horizontal(Int)
}
