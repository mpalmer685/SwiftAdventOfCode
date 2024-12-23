import AOCKit

struct MonkeyMarket: Puzzle, Sendable {
    static let day = 22

    func part1(input: Input) throws -> Int {
        let codes = input.lines.integers
        return sync {
            await codes.concurrentMap { start in
                secretNumbers(startingWith: start).last!
            }.sum
        }
    }

    func part2(input: Input) throws -> Int {
        let codes = input.lines.integers
        let sequences = sync {
            await codes.concurrentMap { salesOpportunities(for: $0) }
        }

        let sales = sequences.reduce([[Int]: Int]()) { sales, sequences in
            sales.merging(sequences, uniquingKeysWith: +)
        }

        return sales.values.max()!
    }

    private func secretNumbers(startingWith start: Int) -> [Int] {
        (0 ..< 2000).reduce(into: [start]) { numbers, _ in
            numbers.append(nextValue(for: numbers.last!))
        }
    }

    private func salesOpportunities(for start: Int) -> [[Int]: Int] {
        secretNumbers(startingWith: start)
            .windows(ofCount: 5)
            .reduce(into: [:]) { sales, window in
                let prices = window.map { $0 % 10 }
                let sequence = prices.adjacentPairs().map { $1 - $0 }
                guard sales[sequence] == nil else { return }
                sales[sequence] = prices.last!
            }
    }

    private typealias Transform = (Int) -> Int

    private func nextValue(for value: Int) -> Int {
        let steps: [Transform] = [
            { value in (value * 64).mixed(with: value).pruned() },
            { value in (value / 32).mixed(with: value).pruned() },
            { value in (value * 2048).mixed(with: value).pruned() },
        ]

        return steps.reduce(value) { value, transform in transform(value) }
    }
}

private extension Int {
    func mixed(with value: Int) -> Int {
        self ^ value
    }

    func pruned() -> Int {
        self % 16_777_216
    }
}

extension MonkeyMarket: TestablePuzzle {
    var testCases: [TestCase<Int, Int>] {
        [
            .init(input: .example(1), part1: 37_327_623),
            .init(input: .example(2), part2: 23),
        ]
    }
}
