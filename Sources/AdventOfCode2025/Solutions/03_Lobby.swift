import AOCKit

struct Lobby: Puzzle {
    static let day = 3

    func part1(input: Input) async throws -> Int {
        input.lines.digits.sum { maximumJoltage(for: $0, withDigits: 2) }
    }

    func part2(input: Input) async throws -> Int {
        input.lines.digits.sum { maximumJoltage(for: $0, withDigits: 12) }
    }

    private func maximumJoltage(for batteries: [Int], withDigits digits: Int) -> Int {
        var total = 0
        var startIndex = batteries.startIndex

        for digit in stride(from: digits, through: 1, by: -1) {
            guard let indexOfMax = batteries[startIndex...]
                .dropLast(digit - 1)
                .indices
                .max(by: { batteries[$0] < batteries[$1] })
            else {
                fatalError("No maximum joltage found")
            }
            let max = batteries[indexOfMax]
            startIndex = batteries.index(after: indexOfMax)
            total = total * 10 + max
        }

        return total
    }
}

extension Lobby: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 357, part2: 3_121_910_778_619),
        ]
    }
}
