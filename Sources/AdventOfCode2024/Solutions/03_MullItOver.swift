import AOCKit

private nonisolated(unsafe) let instructionPattern = /mul\((\d{1,3}),(\d{1,3})\)/

struct MullItOver: Puzzle {
    static let day = 3

    func part1(input: Input) throws -> Int {
        input.raw.matches(of: instructionPattern)
            .map { match in
                let (_, left, right) = match.output
                return Int(left)! * Int(right)!
            }
            .sum
    }

    func part2(input: Input) throws -> Int {
        var scanner = Scanner(input.raw)
        var enabled = true
        var sum = 0

        while scanner.hasMore {
            if scanner.skip("do()") {
                enabled = true
            } else if scanner.skip("don't()") {
                enabled = false
            } else if let match = scanner.scan(using: instructionPattern) {
                let (_, left, right) = match.output
                sum += enabled ? Int(left)! * Int(right)! : 0
            } else {
                scanner.next()
            }
        }

        return sum
    }
}

extension MullItOver: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(
                .raw(
                    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
                ),
            ).expects(part1: 161),
            .given(
                .raw(
                    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
                ),
            ).expects(part2: 48),
        ]
    }
}
