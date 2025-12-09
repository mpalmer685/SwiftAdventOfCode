import AOCKit

struct TrashCompactor: Puzzle {
    static let day = 6

    func part1(input: Input) async throws -> Int {
        let numberLines = parseHorizontalNumbers(from: input.lines.dropLast())
        let operations = parseOperators(from: input.lines.last!)
        let problems = zip(numberLines, operations).map { Problem(numbers: $0.0, operation: $0.1) }

        return problems.sum(of: \.solution)
    }

    func part2(input: Input) async throws -> Int {
        let numberLines = parseVerticalNumbers(from: input.lines.dropLast())
        let operations = parseOperators(from: input.lines.last!)
        let problems = zip(numberLines, operations).map { Problem(numbers: $0.0, operation: $0.1) }

        return problems.sum(of: \.solution)
    }

    private func parseOperators(from line: Line) -> [Problem.Operation] {
        line.words.map { word in
            guard let operation = Problem.Operation(rawValue: word.raw) else {
                fatalError("Unknown operation \(word)")
            }
            return operation
        }
    }

    private func parseHorizontalNumbers(from lines: [Line]) -> [[Int]] {
        lines.map(\.integers).transposed()
    }

    private func parseVerticalNumbers(from lines: [Line]) -> [[Int]] {
        lines.map(\.characters)
            .transposed()
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .split(whereSeparator: \.isEmpty)
            .map { $0.map { Int($0)! } }
    }
}

private struct Problem {
    enum Operation: String {
        case add = "+"
        case multiply = "*"
    }

    let numbers: [Int]
    let operation: Operation

    var solution: Int {
        switch operation {
            case .add: numbers.sum
            case .multiply: numbers.product
        }
    }
}

private extension Collection where Iterator.Element: RandomAccessCollection {
    func transposed() -> [[Iterator.Element.Element]] {
        guard let firstRow = first else { return [] }
        return firstRow.indices.map { index in
            self.map { $0[index] }
        }
    }
}

extension TrashCompactor: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .given(.example).expects(part1: 4_277_556, part2: 3_263_827),
        ]
    }
}
