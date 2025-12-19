import AOCKit

struct NoSuchThingAsTooMuch: Puzzle {
    static let day = 17

    func part1(input: Input) async throws -> Int {
        try await part1(input: input, 150)
    }

    func part1(input: Input, _ goal: Int) async throws -> Int {
        input.lines.integers
            .combinations(ofCount: 1...)
            .count { $0.sum == goal }
    }

    func part2(input: Input) async throws -> Int {
        try await part2(input: input, 150)
    }

    func part2(input: Input, _ goal: Int) async throws -> Int {
        let combinations = input.lines.integers
            .combinations(ofCount: 1...)
            .filter { $0.sum == goal }

        guard let minCount = combinations.min(of: \.count) else {
            fatalError("No combinations found")
        }
        return combinations.count { $0.count == minCount }
    }
}

extension NoSuchThingAsTooMuch: TestablePuzzleWithConfig {
    var testCases: [TestCaseWithConfig<Int, Int, Int>] {
        [
            .given(.raw([20, 15, 10, 5, 5].map(String.init).joined(separator: "\n")), config: 25)
                .expects(part1: 4, part2: 3),
        ]
    }
}
