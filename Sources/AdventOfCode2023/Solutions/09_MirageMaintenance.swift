import AOCKit

struct MirageMaintenance: Puzzle {
    static let day = 9

    // static let rawInput: String? = """
    // 0 3 6 9 12 15
    // 1 3 6 10 15 21
    // 10 13 16 21 30 45
    // """

    func part1(input: Input) throws -> Int {
        input.lines.sum { line in
            expand(line.integers).nextValue
        }
    }

    func part2(input: Input) throws -> Int {
        input.lines.sum { line in
            expand(line.integers).previousValue
        }
    }

    private func expand(_ sequence: [Int]) -> (previousValue: Int, nextValue: Int) {
        if sequence.allSatisfy({ $0 == 0 }) {
            return (0, 0)
        }

        let differences = sequence.adjacentPairs().map { $1 - $0 }
        let (previousValue, nextValue) = expand(differences)
        return (sequence.first! - previousValue, sequence.last! + nextValue)
    }
}
