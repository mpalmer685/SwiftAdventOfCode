import AOCKit

struct CalorieCounting: Puzzle {
    static let day = 1

    func part1() throws -> Int {
        input().lines.split(whereSeparator: \.isEmpty).map(\.integers.sum).max()!
    }

    func part2() throws -> Int {
        input().lines.split(whereSeparator: \.isEmpty).map(\.integers.sum).max(count: 3).sum
    }
}
