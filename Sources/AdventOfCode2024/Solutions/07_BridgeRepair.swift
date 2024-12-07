import AOCKit

struct BridgeRepair: Puzzle {
    static let day = 7

    func part1(input: Input) throws -> Int {
        let tests = parse(input, with: [(+), (*)])
        return tests.filter { $0.isCalibrated() }.map(\.target).sum
    }

    func part2(input: Input) throws -> Int {
        let tests = parse(input, with: [(+), (*)] + [concat])
        return tests.filter { $0.isCalibrated() }.map(\.target).sum
    }

    private func parse(
        _ input: Input,
        with operators: [CalibrationEquation.Operator]
    ) -> [CalibrationEquation] {
        input.lines.map { line in
            let ints = line.integers
            return CalibrationEquation(
                target: ints[0],
                operands: Array(ints[1...]),
                operators: operators
            )
        }
    }

    private func concat(_ a: Int, _ b: Int) -> Int {
        Int("\(a)\(b)")!
    }
}

private struct CalibrationEquation {
    typealias Operator = (Int, Int) -> Int

    let target: Int
    let operands: [Int]
    let operators: [Operator]

    func isCalibrated() -> Bool {
        operands[1...]
            .reduce([operands[0]]) { totals, next in
                totals
                    .filter { $0 <= target }
                    .flatMap { current in
                        operators.map { op in op(current, next) }
                    }
            }
            .contains(target)
    }
}

extension BridgeRepair: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example, part1: 3749, part2: 11387),
        ]
    }
}
