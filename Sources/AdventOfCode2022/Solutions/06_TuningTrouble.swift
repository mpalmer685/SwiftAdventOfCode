import AOCKit

struct TuningTrouble: Puzzle {
    static let day = 6

    func part1(input: Input) throws -> Int {
        input.characters.windows(ofCount: 4).first(where: \.allUnique)!.endIndex
    }

    func part2(input: Input) throws -> Int {
        input.characters.windows(ofCount: 14).first(where: \.allUnique)!.endIndex
    }
}

private extension Collection where Element: Hashable {
    var allUnique: Bool {
        var seen = Set<Element>()
        for item in self {
            if seen.contains(item) { return false }
            seen.insert(item)
        }
        return true
    }
}
