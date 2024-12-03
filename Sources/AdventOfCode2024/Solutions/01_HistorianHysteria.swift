import AOCKit

struct HistorianHysteria: Puzzle {
    static let day = 1

    func part1(input: Input) throws -> Int {
        var (first, second) = parseLists(from: input)
        first.sort()
        second.sort()
        return zip(first, second).map { abs($0 - $1) }.sum
    }

    func part2(input: Input) throws -> Int {
        let (first, second) = parseLists(from: input)
        let counts = countOccurrences(from: first, in: second)

        return first.map { $0 * counts[$0]! }.sum
    }

    private func parseLists(from input: Input) -> ([Int], [Int]) {
        let pairs = input.lines.map(\.integers).map { ($0[0], $0[1]) }
        return (pairs.map(\.0), pairs.map(\.1))
    }

    private func countOccurrences(from left: [Int], in right: [Int]) -> [Int: Int] {
        Set(left).reduce(into: [:]) { result, element in
            result[element] = right.count(of: element)
        }
    }
}

extension HistorianHysteria: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(
                input: .example,
                part1: 11,
                part2: 31
            ),
            .init(input: .file("double-digits.example"), part1: 11),
        ]
    }
}
