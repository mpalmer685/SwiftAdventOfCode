import AOCKit

struct RucksackReorganization: Puzzle {
    static let day = 3

    func part1(input: Input) throws -> Int {
        input.lines.raw.map { line -> Int in
            let duplicate = line.dividing(into: 2).commonElements.first!
            return duplicate.priority
        }.sum
    }

    func part2(input: Input) throws -> Int {
        input.lines.raw.chunks(ofCount: 3).map { lines -> Int in
            let shared = lines.commonElements.first!
            return shared.priority
        }.sum
    }
}

private extension Character {
    var priority: Int {
        alphabeticOrdinal! + (isUppercase ? 26 : 0)
    }
}
