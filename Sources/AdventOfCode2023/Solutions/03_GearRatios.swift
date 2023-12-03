import AOCKit

struct GearRatios: Puzzle {
    static let day = 3

    // static let rawInput: String? = """
    // 467..114..
    // ...*......
    // ..35..633.
    // ......#...
    // 617*......
    // .....+.58.
    // ..592.....
    // ......755.
    // ...$.*....
    // .664.598..
    // """

    func part1(input: Input) throws -> Int {
        let grid = Grid(input.lines.characters)
        let parts = findParts(in: grid)
        return parts.sum(of: \.partNumber)
    }

    func part2(input: Input) throws -> Int {
        let grid = Grid(input.lines.characters)
        let parts = findParts(in: grid)

        var gears = [Int]()
        for point in grid.points where grid[point] == "*" {
            var adjacentParts = Set<Part>()
            for neighbor in point.neighbors
                where grid.contains(neighbor) && grid[neighbor].isWholeNumber
            {
                guard let part = parts
                    .first(where: { $0.row == neighbor.y && $0.range.contains(neighbor.x) })
                else {
                    fatalError("No part found for location \(neighbor)")
                }
                adjacentParts.insert(part)
            }

            guard adjacentParts.count == 2 else { continue }

            gears.append(adjacentParts.product(of: \.partNumber))
        }

        return gears.sum
    }

    private func findParts(in grid: Schematic) -> Set<Part> {
        var parts = Set<Part>()
        for point in grid.points where grid[point].isSymbol {
            for neighbor in point.neighbors
                where grid.contains(neighbor) && grid[neighbor].isWholeNumber
            {
                let y = neighbor.y
                var current = neighbor
                while grid.contains(current - .x), grid[current - .x].isWholeNumber {
                    current -= .x
                }
                let start = current.x
                current = neighbor
                while grid.contains(current + .x), grid[current + .x].isWholeNumber {
                    current += .x
                }
                let end = current.x
                let digits = Array(start ... end).map { x in
                    Int.from(digit: grid[x, y])!
                }
                let partNumber = Int(digits: digits)
                parts.insert(Part(row: y, range: start ... end, partNumber: partNumber))
            }
        }
        return parts
    }
}

private typealias Schematic = Grid<Character>

private struct Part: Hashable {
    let row: Int
    let range: ClosedRange<Int>
    let partNumber: Int
}

private extension Character {
    var isSymbol: Bool { !isNumber && self != "." }
}
