import AOCKit

struct TobogganTrajectory: Puzzle {
    static let day = 3

    func part1() throws -> Int {
        let field = input().lines.characters
        return traverse(field, dx: 3, dy: 1)
    }

    func part2() throws -> Int {
        let field = input().lines.characters
        let slopes: [(dx: Int, dy: Int)] = [
            (dx: 1, dy: 1),
            (dx: 3, dy: 1),
            (dx: 5, dy: 1),
            (dx: 7, dy: 1),
            (dx: 1, dy: 2),
        ]
        return slopes.reduce(1) { $0 * traverse(field, dx: $1.dx, dy: $1.dy) }
    }

    private func traverse(_ field: [[Character]], dx: Int, dy: Int) -> Int {
        var x = 0, y = 0
        var total = 0
        while y < field.count {
            let row = field[y]
            let cell = row[x % row.count]
            if cell == "#" {
                total += 1
            }
            x += dx
            y += dy
        }
        return total
    }
}
